require "djinni"

class CopyWish < Djinni::Wish
    def aliases
        return ["copy", "cp"]
    end

    def description
        return "Copy the specified profile"
    end

    def execute(args, djinni_env = {})
        if (args.split(" ").length != 2)
            usage
            return
        end

        config = djinni_env["config"]

        name, new = args.split(" ")
        if (!config.has_profile?(name))
            puts "Profile does not exist: #{name}"
        elsif (config.has_profile?(new))
            puts "Profile already exists: #{new}"
        else
            profiles = config.parse_profiles
            profiles[new] = profiles[name].clone
            profiles[new].name(new)
            config.set_profiles(profiles)
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
        puts "#{aliases.join(", ")} <name> <new_name>"
        puts "    #{description}."
    end
end
