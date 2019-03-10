require "djinni"

class AddWish < Djinni::Wish
    def aliases
        return ["add", "new"]
    end

    def description
        return "Create a new profile"
    end

    def execute(args, djinni_env = {})
        if (args.split(" ").length != 2)
            usage
            return
        end

        config = djinni_env["config"]
        c, n = args.split(" ")

        if (config.has_profile?(n))
            puts "Profile already exists: #{n}"
        elsif (!@classes.has_key?(c))
            puts "Class does not exist: #{c}"
        else
            profiles = config.parse_profiles
            profiles[n] = Zoom::Profile.profile_by_name(c).new(n)
            config.set_profiles(profiles)
        end
    end

    def initialize
        @classes = Hash.new
        [Zoom::Profile].concat(Zoom::Profile.subclasses).each do |c|
            @classes[c.to_s] = c.new(c.to_s).to_s.split("\n")[1].strip
        end
    end

    def tab_complete(input, djinni_env = {})
        return [{}, "", ""] if (input.include?(" "))

        completions = @classes.select do |clas, desc|
            clas.downcase.start_with?(input.downcase)
        end

        return [completions, input, " "]
    end

    def usage
        puts "#{aliases.join(", ")} <class> <name>"
        puts "    #{description}."
        puts
        puts "CLASSES"
        @classes.each do |clas, desc|
            puts "    #{clas}"
        end
    end
end
