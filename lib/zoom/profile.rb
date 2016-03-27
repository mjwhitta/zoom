require "hilighter"
require "scoobydoo"
require "shellwords"

class Zoom::Profile < Hash
    attr_reader :pattern
    attr_reader :taggable

    def after(a = nil)
        self["after"] = a if (a)
        return self["after"].strip
    end

    def before(b = nil)
        self["before"] = b if (b)
        return self["before"].strip
    end

    def class_name
        return self["class"]
    end

    def exe(args, pattern)
        # Use hard-coded pattern if defined
        pattern = @pattern if (@pattern && !@pattern.empty?)

        # If not pattern and no after, then return nothing
        if (pattern.nil? || pattern.empty?)
            return "" if (after.nil? || after.empty? || after == ".")
        end

        # Emulate grep
        case operator.split("/")[-1]
        when "ack", "ack-grep"
            str = [
                before,
                operator,
                "-H --nobreak --nocolor --noheading -s",
                flags
            ].join(" ").strip
            return %x(#{str} #{args} #{pattern.shellescape} #{after})
        when "ag"
            str = [
                before,
                operator,
                "--filename --nobreak --nocolor --noheading --silent",
                flags
            ].join(" ").strip
            return %x(#{str} #{args} #{pattern.shellescape} #{after})
        when "find"
            str = [before, operator, flags].join(" ").strip
            return %x(#{str} #{args} \"#{pattern}\" #{after})
        when "grep"
            str = [
                before,
                operator,
                "--color=never -EHnRs",
                "--exclude-dir=.bzr",
                "--exclude-dir=.git",
                "--exclude-dir=.svn",
                flags
            ].join(" ").strip
            return %x(#{str} #{args} #{pattern.shellescape} #{after})
        when "pt"
            str = [
                before,
                operator,
                "-e --nocolor --nogroup",
                flags
            ].join(" ").strip
            return %x(#{str} #{args} #{pattern.shellescape} #{after})
        else
            str = [before, operator, flags].join(" ").strip
            return %x(#{str} #{args} #{pattern} #{after})
        end
    end

    def flags(f = nil)
        self["flags"] = f if (f)
        return self["flags"].strip
    end

    def self.from_json(json)
        begin
            return profile_by_name(json["class"]).new(
                json["name"],
                json["operator"].nil? ? "" : json["operator"],
                json["flags"].nil? ? "" : json["flags"],
                json["before"].nil? ? "" : json["before"],
                json["after"].nil? ? "" : json["after"]
            )
        rescue NoMethodError
            raise Zoom::Error::ProfileNotNamed.new(json)
        rescue NameError
            raise Zoom::Error::ProfileClassUnknown.new(json["class"])
        end
    end

    def go(editor, results)
        Zoom::Editor.new(editor).open(results)
    end

    def hilight_after(str)
        return str if (!Zoom.hilight?)
        return str.yellow
    end
    private :hilight_after

    def hilight_before(str)
        return str if (!Zoom.hilight?)
        return str.yellow
    end
    private :hilight_before

    def hilight_class
        return class_name if (!Zoom.hilight?)
        return class_name.cyan
    end
    private :hilight_class

    def hilight_flags(str)
        return str if (!Zoom.hilight?)
        return str.magenta
    end
    private :hilight_flags

    def hilight_name
        return name if (!Zoom.hilight?)
        return name.white
    end
    private :hilight_name

    def hilight_operator(str)
        return str if (!Zoom.hilight?)
        return str.green
    end
    private :hilight_operator

    def hilight_pattern(str)
        return str if (!Zoom.hilight?)
        return str
    end
    private :hilight_pattern

    def initialize(n, o = "echo", f = "#", b = "", a = "")
        self["class"] = self.class.to_s
        after(a)
        before(b)
        flags(f.split(" ").uniq.join(" "))
        name(n)
        operator(o)

        @pattern = "" # Setting this will override user input
        @taggable = false
    end

    def name(n = nil)
        self["name"] = n if (n)
        return self["name"].strip
    end

    def operator(o = nil)
        if (o)
            op = ScoobyDoo.where_are_you(o)
            raise Zoom::Error::ExecutableNotFound.new(o) if (op.nil?)
            self["operator"] = o
        end
        return self["operator"].strip
    end

    def self.profile_by_name(clas)
        clas.split("::").inject(Object) do |mod, class_name|
            mod.const_get(class_name)
        end
    end

    def self.subclasses
        ObjectSpace.each_object(Class).select do |clas|
            if (clas < self)
                begin
                    clas.new(clas.to_s)
                    true
                rescue Zoom::Error::ExecutableNotFound
                    false
                end
            else
                false
            end
        end
    end

    def to_s
        ret = Array.new
        ret.push(hilight_name)
        ret.push("#{hilight_class}\n")
        ret.push(hilight_before(before)) if (!before.empty?)
        ret.push(hilight_operator(operator)) if (!operator.empty?)
        ret.push(hilight_flags(flags)) if (!flags.empty?)
        if (@pattern.nil? || @pattern.empty?)
            ret.push(hilight_pattern("PATTERN"))
        else
            ret.push(hilight_pattern("\"#{@pattern}\""))
        end
        ret.push(hilight_after(after)) if (!after.empty?)
        return ret.join(" ").strip
    end
end

require "zoom/profile/ack"
require "zoom/profile/ag"
require "zoom/profile/find"
require "zoom/profile/grep"
require "zoom/profile/passwords"
require "zoom/profile/pt"
