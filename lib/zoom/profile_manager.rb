require "pathname"
require "scoobydoo"

# Load custom profiles
config_dir = Pathname.new("~/.config/zoom").expand_path
if (config_dir.exist?)
    Dir["#{config_dir}/*.rb"].each do |file|
        require_relative file
    end
end

class Zoom::ProfileManager
    @@ranking = [
        ["ag", "Zoom::Profile::Ag", "-Su"],
        ["pt", "Zoom::Profile::Pt", "-SU --hidden"],
        ["ack", "Zoom::Profile::Ack", ""],
        ["ack-grep", "Zoom::Profile::Ack", ""],
        ["grep", "Zoom::Profile::Grep", "-ai"],
        ["find", "Zoom::Profile::Find", ""]
    ]

    def self.default_profile
        @@ranking.each do |op, clas, all|
            return op if (ScoobyDoo.where_are_you(op))
        end
        return nil # shouldn't happen
    end

    def self.default_profiles
        profiles = Hash.new

        @@ranking.each do |op, clas, all|
            if (ScoobyDoo.where_are_you(op))
                name = op.gsub("-grep", "")
                obj = Zoom::Profile.profile_by_name(clas)
                profiles[name] = obj.new(name)
                if (!all.empty?)
                    profiles["all"] ||= obj.new("all", name, all)
                end
            end
        end

        return profiles
    end

    def self.security_profiles
        return [
            Zoom::Profile::Passwords.new("passwords"),
            Zoom::Profile::UnsafeC.new("unsafe_c"),
            Zoom::Profile::UnsafeJava.new("unsafe_java"),
            Zoom::Profile::UnsafeJs.new("unsafe_js"),
            Zoom::Profile::UnsafePhp.new("unsafe_php"),
            Zoom::Profile::UnsafePython.new("unsafe_python")
        ]
    end
end
