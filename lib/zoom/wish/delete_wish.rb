require "djinni"

class DeleteWish < Djinni::Wish
    def aliases
        return ["delete", "rm"]
    end

    def description
        return "Delete the specifed profile"
    end

    def execute(args, djinni_env = {})
        config = djinni_env["config"]
        profiles = config.parse_profiles
        args.split(" ").each do |arg|
            if (!config.has_profile?(arg))
                puts "Profile does not exist: #{arg}"
            elsif (config.get_current_profile_name == arg)
                puts "Can't delete current profile: #{arg}"
            else
                profiles.delete(arg)
            end
        end
        config.set_profiles(profiles)
    end

    def tab_complete(input, djinni_env = {})
        profiles = djinni_env["config"].parse_profiles
        completions = Hash.new

        profiles.keys.sort do |a, b|
            a.downcase <=> b.downcase
        end.each do |name|
            profile = profiles[name]
            completions[name] = profile.to_s.split("\n")[1].strip
        end

        last = input.rpartition(" ")[-1]

        completions.keep_if do |name, desc|
            name.downcase.start_with?(last.downcase)
        end

        return [completions, last, " "]
    end

    def usage
        puts "#{aliases.join(", ")} <name>...[name]"
        puts "    #{description}."
    end
end
