require "pathname"
require "scoobydoo"

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

        Zoom::Profile.subclasses.each do |clas|
            case clas.to_s
            when /^Zoom::SecurityProfile.*/
                # Ignore these
            when /^Zoom::Profile::(Ag|Ack|Find|Grep|Pt)/
                # Ignore these
            else
                # Custom classes
                c = clas.new
                profiles[c.name] = c
            end
        end

        return profiles
    end

    def self.security_profiles
        profiles = Array.new
        Zoom::SecurityProfile.subclasses.each do |clas|
            profiles.push(clas.new)
        end
        return profiles
    end
end
