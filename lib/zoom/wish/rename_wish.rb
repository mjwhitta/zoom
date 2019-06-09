require "djinni"

class RenameWish < Djinni::Wish
    def aliases
        return ["mv", "rename"]
    end

    def description
        return "Rename the specified profile"
    end

    def execute(args, djinni_env = {})
        if (args.split(" ").length != 2)
            usage
            return
        end

        config = djinni_env["config"]

        old, new = args.split(" ")
        if (!config.has_profile?(old))
            puts("Profile does not exist: #{old}")
        elsif (config.has_profile?(new))
            puts("Profile already exists: #{new}")
        else
            profiles = config.parse_profiles
            profiles[new] = profiles.delete(old)
            profiles[new].name(new)
            config.set_profiles(profiles)

            # Update prompt
            if (config.get_current_profile_name == old)
                config.set_current_profile_name(new)
                prompt_color = djinni_env["prompt_color"]
                if (prompt_color)
                    prompt = "zoom(#{new})> ".send(prompt_color)
                else
                    prompt = "zoom(#{new})> "
                end
                djinni_env["djinni_prompt"] = prompt
            end
        end
    end

    def tab_complete(input, djinni_env = {})
        return [{}, "", ""] if (input.include?(" "))

        profiles = djinni_env["config"].parse_profiles
        completions = Hash.new

        profiles.keys.sort do |a, b|
            a.downcase <=> b.downcase
        end.each do |name|
            profile = profiles[name]
            completions[name] = profile.to_s.split("\n")[1].strip
        end

        completions.keep_if do |name, desc|
            name.downcase.start_with?(input.downcase)
        end

        return [completions, input, " "]
    end

    def usage
        puts("#{aliases.join(", ")} <old_name> <new_name>")
        puts("    #{description}.")
    end
end
