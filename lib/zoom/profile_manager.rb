require "pathname"
require "scoobydoo"

class Zoom::ProfileManager
    @@ranking = [
        ["rg", "Zoom::Profile::Rg"],
        ["ag", "Zoom::Profile::Ag"],
        ["grep", "Zoom::Profile::Grep"],
        ["pt", "Zoom::Profile::Pt"],
        ["ack", "Zoom::Profile::Ack"],
        ["ack-grep", "Zoom::Profile::Ack"],
        ["find", "Zoom::Profile::Find"]
    ]
    @@tool = nil

    def self.class_by_tool(t)
        found = @@ranking.select do |tool, clas|
            t == tool
        end
        return found[0][1] if (!found.empty?)
        return nil
    end

    def self.default_class
        if (@@tool && ScoobyDoo.where_are_you(@@tool))
            return class_by_tool(@@tool)
        end

        @@ranking.each do |tool, clas|
            return clas if (ScoobyDoo.where_are_you(tool))
        end

        return nil # shouldn't happen
    end

    def self.default_profiles
        profiles = Hash.new

        @@ranking.each do |tool, clas|
            if (ScoobyDoo.where_are_you(tool))
                name = tool.gsub("-grep", "")
                obj = Zoom::Profile.profile_by_name(clas)
                profiles[name] = obj.new(name)
            end
        end

        Zoom::Profile.subclasses.each do |clas|
            case clas.to_s
            when /^Zoom::SecurityProfile.*/
                # Ignore these
            when /^Zoom::Profile::(Ag|Ack|Find|Grep|Pt|Rg)/
                # Ignore these
            else
                # Custom classes
                c = clas.new
                profiles[c.name] = c
            end
        end

        return profiles
    end

    def self.default_tool
        if (@@tool && ScoobyDoo.where_are_you(@@tool))
            return @@tool
        end

        @@ranking.each do |tool, clas|
            return tool if (ScoobyDoo.where_are_you(tool))
        end

        return nil # shouldn't happen
    end

    def self.force_tool(tool = nil)
        if (tool == "ack")
            tool = "ack-grep" if (ScoobyDoo.where_are_you("ack-grep"))
        end

        tool = nil if (tool && !ScoobyDoo.where_are_you(tool))

        @@tool = tool
    end

    def self.security_profiles
        profiles = Array.new
        Zoom::SecurityProfile.subclasses.each do |clas|
            profiles.push(clas.new)
        end
        return profiles
    end
end
