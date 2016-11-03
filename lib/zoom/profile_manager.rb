require "fagin"
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

        return profiles
    end

    def self.security_profiles
        profs = Array.new
        Zoom::SecurityProfile.subclasses.each do |clas|
            # Convert camelcase class to unscore separated string
            name = clas.to_s.split("::")[-1]
            name.gsub!(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
            name.gsub!(/([a-z0-9])([A-Z])/, "\\1_\\2")
            name.tr!("-", "_")
            profs.push(clas.new(name.downcase))
        end
        return profs
    end
end
