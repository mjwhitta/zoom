require "djinni"

class UseWish < Djinni::Wish
    def aliases
        return ["use"]
    end

    def description
        return "Set the specifed profile as the current profile name"
    end

    def execute(args, djinni_env = {})
        if (args.include?(" "))
            usage
            return
        end

        config = djinni_env["config"]

        if (!config.has_profile?(args))
            puts("Profile does not exist: #{args}")
            return
        end

        config.set_current_profile_name(args)

        # Update prompt
        prompt_color = djinni_env["prompt_color"]
        if (prompt_color)
            prompt = "zoom(#{args})> ".send(prompt_color)
        else
            prompt = "zoom(#{args})> "
        end
        djinni_env["djinni_prompt"] = prompt
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
        puts("#{aliases.join(", ")} <name>")
        puts("    #{description}.")
    end
end
