require "zoom/profile"
require "zoom/profile/ag"
require "zoom/profile/ack"
require "zoom/profile/grep"

class Zoom::Profile::Passwords < Zoom::Profile
    def colors
        return @profile.colors
    end

    def exe(args, pattern)
        @profile.exe(args, pattern)
    end

    def info
        [
            "Class   : #{self.class.to_s}",
            "Prepend : #{@profile.prepend}",
            "Operator: #{@profile.operator}",
            "Flags   : #{@profile.flags}",
            "Append  : #{@profile.append}"
        ].join("\n").strip
    end

    def initialize(
        operator = nil,
        flags = "",
        envprepend = "",
        append = ""
    )
        @passwd_regex = "\"pass(word|wd)?[^:=,>]? *[:=,>]\""

        if (ScoobyDoo.where_are_you("ag"))
            @profile = Zoom::Profile::Ag.new(
                nil,
                "-uS",
                "",
                @passwd_regex
            )
        elsif (
            ScoobyDoo.where_are_you("ack") ||
            ScoobyDoo.where_are_you("ack-grep")
        )
            @profile = Zoom::Profile::Ack.new(
                nil,
                "--smart-case",
                "",
                @passwd_regex
            )
        else
            @profile = Zoom::Profile::Grep.new(
                nil,
                "--color=always -EHinR",
                "",
                @passwd_regex
            )
        end

        super(
            @profile.operator,
            @profile.flags,
            @profile.prepend,
            @profile.append
        )
        @immutable = true
        @taggable = true
    end

    def to_s
        return @porfile.to_s
    end
end
