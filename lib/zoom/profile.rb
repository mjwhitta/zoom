require "scoobydoo"
require "shellwords"
require "zoom/error/profile_class_unknown_error"

class Zoom::Profile < Hash
    attr_accessor :immutable
    attr_accessor :taggable

    def append(append = nil)
        self["append"] = append if (append)
        return self["append"]
    end

    def colors
        # TODO color support
        ""
    end

    def exe(args, pattern)
        system("#{self.to_s} #{args} #{pattern} #{self.append}")
    end

    def flags(flags = nil)
        self["flags"] = flags if (flags)
        return self["flags"]
    end

    def self.from_json(json)
        begin
            return profile_by_name(json["class"]).new(
                json["operator"].nil? ? "" : json["operator"],
                json["flags"].nil? ? "" : json["flags"],
                json["prepend"].nil? ? "" : json["prepend"],
                json["append"].nil? ? "" : json["append"]
            )
        rescue NameError => e
            raise Zoom::Error::ProfileClassUnknownError.new(
                json["class"]
            )
        end
    end

    def info
        [
            "Class   : #{self.class.to_s}",
            "Prepend : #{self["prepend"]}",
            "Operator: #{self["operator"]}",
            "Flags   : #{self["flags"]}",
            "Append  : #{self["append"]}"
        ].join("\n").strip
    end

    def initialize(
        operator = "echo",
        flags = "#",
        envprepend = "",
        append = ""
    )
        self["class"] = self.class.to_s
        self.flags(flags)
        self.prepend(envprepend)
        self.append(append)
        self.operator(operator)

        @immutable = false
        @pager = "z --pager"
        @taggable = false
    end

    def operator(operator = nil)
        if (operator)
            op = ScoobyDoo.where_are_you(operator)
            if (op)
                self["operator"] = op
            else
                self["operator"] = ScoobyDoo.where_are_you("echo")
                flags("")
                prepend("")
                append("#{operator} is not installed!")
            end
        end
        return self["operator"]
    end

    def prepend(envprepend = nil)
        self["prepend"] = envprepend if (envprepend)
        return self["prepend"]
    end

    def self.profile_by_name(clas)
        clas.split("::").inject(Object) do |mod, class_name|
            mod.const_get(class_name)
        end
    end

    def to_s
        [
            self.colors,
            self["prepend"],
            self["operator"],
            self["flags"]
        ].join(" ").strip
    end
end

require "zoom/profile/ack"
require "zoom/profile/ag"
require "zoom/profile/find"
require "zoom/profile/grep"
require "zoom/profile/passwords"
require "zoom/profile/pt"
