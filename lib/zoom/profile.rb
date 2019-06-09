require "hilighter"
require "scoobydoo"
require "shellwords"

class Zoom::Profile < Hash
    attr_accessor :exts
    attr_accessor :files
    attr_accessor :format_flags
    attr_accessor :regex
    attr_accessor :taggable

    def after(a = nil)
        self["after"] = a.strip if (a)
        self["after"] ||= ""
        return self["after"]
    end

    def before(b = nil)
        self["before"] = b.strip if (b)
        self["before"] ||= ""
        return self["before"]
    end

    def camel_case_to_underscore(clas)
        # Convert camelcase class to unscore separated string
        name = clas.to_s.split("::")[-1]
        name.gsub!(/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
        name.gsub!(/([a-z0-9])([A-Z])/, "\\1_\\2")
        name.tr!("-", "_")
        return name.downcase
    end
    private :camel_case_to_underscore

    def class_name
        return self["class"]
    end

    def exe(header)
        # Emulate grep
        cmd = [
            before,
            tool,
            @format_flags,
            flags,
            only_exts_and_files,
            header["translated"],
            header["args"],
            "--",
            header["regex"].shellescape,
            header["paths"],
            after
        ].join(" ").strip

        if (header.has_key?("debug") && header["debug"])
            puts(cmd)
            return ""
        else
            return %x(#{cmd})
        end
    end

    def flags(f = nil)
        self["flags"] = f.strip if (f)
        self["flags"] ||= ""
        return self["flags"]
    end

    def self.from_json(json)
        begin
            return profile_by_name(json["class"]).new(
                json["name"],
                json["tool"].nil? ? "" : json["tool"],
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

    def grep_like_format_flags(all = false)
        @format_flags = "" # Set this to mirror basic grep
        @taggable = false # Should results be tagged like grep
    end

    def grep_like_tags?
        return @grep_like_tags
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

    def hilight_regex(str)
        return str if (!Zoom.hilight?)
        return str
    end
    private :hilight_regex

    def hilight_tool(str)
        return str if (!Zoom.hilight?)
        return str.green
    end
    private :hilight_tool

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        a ||= ""
        b ||= ""
        f ||= ""
        n ||= camel_case_to_underscore(self.class.to_s)
        t ||= "echo"

        self["class"] = self.class.to_s
        after(a)
        before(b)
        flags(f)
        name(n)
        tool(t)

        @exts = Array.new # Set this to only search specified exts
        @files = Array.new # Set this to noly search specified files
        @regex = "" # Setting this will override user input

        # In case someone overrides grep_like_format_flags
        @format_flags = ""
        @grep_like_tags = true
        @taggable = false

        grep_like_format_flags
    end

    def name(n = nil)
        self["name"] = n.strip if (n)
        self["name"] ||= ""
        return self["name"]
    end

    def only_exts_and_files
        # Do nothing
        return ""
    end

    def preprocess(header)
        return header
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
                    clas.new
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
        ret.push(hilight_tool(tool)) if (!tool.empty?)
        ret.push(hilight_flags(flags)) if (!flags.empty?)
        if (@regex.nil? || @regex.empty?)
            ret.push(hilight_regex("REGEX"))
        else
            ret.push(hilight_regex("\"#{@regex}\""))
        end
        ret.push(hilight_after(after)) if (!after.empty?)
        return ret.join(" ").strip
    end

    def tool(t = nil)
        if (t)
            t.strip!
            tl = ScoobyDoo.where_are_you(t)
            raise Zoom::Error::ExecutableNotFound.new(t) if (tl.nil?)
            self["tool"] = t
        end
        return self["tool"]
    end

    def translate(from)
        return ""
    end
end
