require "djinni"

class EditWish < Djinni::Wish
    def aliases
        return ["config", "edit", "set"]
    end

    def description
        return "Configure profile"
    end

    def execute(args, djinni_env = {})
        n, args = args.split(" ", 2)

        if (args.nil?)
            usage
            return
        end

        config = djinni_env["config"]
        if (!config.has_profile?(n))
            puts "Profile does not exist: #{n}"
            return
        end

        f, found, v = args.partition(" ")

        case f
        when "class", "operator"
            if (found.empty?)
                usage
                return
            end
        end

        profiles = config.get_profiles
        profile = profiles[n]

        case f
        when "after"
            profile.after(v)
        when "before"
            profile.before(v)
        when "class"
            if (!@classes.has_key?(v))
                puts "Class does not exist: #{v}"
                return
            end

            profile = Zoom::Profile.profile_by_name(v).new(n)
            profiles[n] = profile
        when "flags"
            profile.flags(v)
        when "operator"
            profile.operator(v)
        else
            usage
            return
        end

        config.set_profiles(profiles)
    end

    def initialize
        @classes = Hash.new
        [Zoom::Profile].concat(Zoom::Profile.subclasses).each do |c|
            @classes[c.to_s] = c.new(c.to_s).to_s.split("\n")[1].strip
        end
        @fields = {
            "after" => "Append any follow up commands",
            "before" => "Prepend any ENV vars",
            "class" => "Modify the class",
            "flags" => "Specify any additional flags",
            "operator" => "Specify an alternative operator"
        }
    end

    def tab_complete(input, djinni_env = {})
        n, input = input.split(" ", 2)
        n ||= ""

        if (input.nil?)
            profiles = djinni_env["config"].get_profiles
            completions = Hash.new

            profiles.keys.sort do |a, b|
                a.downcase <=> b.downcase
            end.each do |name|
                profile = profiles[name]
                completions[name] = profile.to_s.split("\n")[1].strip
            end

            completions.keep_if do |name, desc|
                name.downcase.start_with?(n.downcase)
            end

            return [completions, n, " "]
        end

        f, found, v = input.rpartition(" ")

        if (found.empty?)
            f = v
            completions = @fields.select do |field, desc|
                field.downcase.start_with?(f.downcase)
            end
            return [completions, f, " "]
        end

        case f
        when "class"
            completions = @classes.select do |clas, desc|
                clas.downcase.start_with?(v.downcase)
            end
            return [completions, v, ""]
        else
            return [{}, "", ""]
        end
    end

    def usage
        puts "#{aliases.join(", ")} <name> <field> <value>"
        puts "    #{description}."
        puts
        puts "FIELDS"
        @fields.each do |field, desc|
            puts "    #{field}"
        end
    end
end
