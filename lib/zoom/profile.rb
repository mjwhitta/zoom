require "hilighter"
require "scoobydoo"
require "shellwords"

class Zoom::Profile < Hash
    attr_reader :pattern
    attr_reader :taggable

    def after(a = nil)
        self["after"] = a.strip if (a)
        return self["after"]
    end

    def before(b = nil)
        self["before"] = b.strip if (b)
        return self["before"]
    end

    def class_name
        return self["class"]
    end

    def exe(args, pattern, paths)
        # Use hard-coded pattern if defined
        if (@pattern && !@pattern.empty?)
            args += " #{pattern}"
            pattern = @pattern
        end

        # If not pattern and no after, then return nothing
        if (pattern.nil? || pattern.empty?)
            return "" if (after.nil? || after.empty? || after == ".")
        end

        # If paths are specified then remove "." for profiles like
        # grep
        after.gsub!(/^\.\s+/, "") if (!paths.empty?)

        # Emulate grep
        case operator.split("/")[-1]
        when "ack", "ack-grep"
            cmd = [
                before,
                operator,
                "-H --nobreak --nocolor --noheading -s",
                flags,
                args,
                pattern.shellescape,
                paths,
                after
            ].join(" ").strip
        when "ag"
            cmd = [
                before,
                operator,
                "--filename --nobreak --nocolor --noheading --silent",
                flags,
                args,
                pattern.shellescape,
                paths,
                after
            ].join(" ").strip
        when "find"
            flags.gsub!(/^\.\s+/, "") if (!paths.empty?)
            cmd = [
                before,
                operator,
                paths,
                flags,
                args,
                "\"#{pattern}\"",
                after
            ].join(" ").strip
        when "grep"
            cmd = [
                before,
                operator,
                "--color=never -EHInRs",
                "--exclude-dir=.bzr",
                "--exclude-dir=.git",
                "--exclude-dir=.git-crypt",
                "--exclude-dir=.svn",
                flags,
                args,
                pattern.shellescape,
                paths,
                after
            ].join(" ").strip
        when "pt"
            cmd = [
                before,
                operator,
                "-e --nocolor --nogroup",
                flags,
                args,
                pattern.shellescape,
                paths,
                after
            ].join(" ").strip
        else
            cmd = [
                before,
                operator,
                flags,
                args,
                pattern,
                paths,
                after
            ].join(" ").strip
        end
        return %x(#{cmd})
    end

    def flags(f = nil)
        self["flags"] = f.strip if (f)
        return self["flags"]
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
        flags(f)
        name(n)
        operator(o)

        @pattern = "" # Setting this will override user input
        @taggable = false
    end

    def name(n = nil)
        self["name"] = n.strip if (n)
        return self["name"]
    end

    def operator(o = nil)
        if (o)
            o.strip!
            op = ScoobyDoo.where_are_you(o)
            raise Zoom::Error::ExecutableNotFound.new(o) if (op.nil?)
            self["operator"] = o
        end
        return self["operator"]
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
