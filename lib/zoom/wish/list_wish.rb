require "djinni"

class ListWish < Djinni::Wish
    def aliases
        return ["la", "list", "ls"]
    end

    def description
        return "List details for current/all profiles"
    end

    def execute(args, djinni_env = {})
        if (!args.empty? && (args != "all"))
            usage
            return
        end

        config = djinni_env["config"]
        input = djinni_env["djinni_input"]
        input = "la" if (!args.empty?)

        case input
        when "la"
            profiles = config.parse_profiles
            profiles.keys.sort do |a, b|
                a.downcase <=> b.downcase
            end.each do |name|
                print_profile(profiles[name])
            end
        else
            profile = config.get_profile(
                config.get_current_profile_name
            )
            print_profile(profile)
        end
    end

    def print_profile(profile)
        first = true
        profile.to_s.scan(/\S.{0,76}\S(?=\s|$)|\S+/).each do |line|
            if (first)
                puts line
                first = false
            else
                puts "    #{line}"
            end
        end
    end
    private :print_profile

    def tab_complete(input, djinni_env = {})
        return [{}, "", ""] if (input.include?(" "))
        return [{"all" => "List all profiles"}, input, ""]
    end

    def usage
        puts "#{aliases.join(", ")} [all]"
        puts "    #{description}."
    end
end
