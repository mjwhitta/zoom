require "ag_profile"
require "ack_profile"
require "grep_profile"
require "shellwords"
require "zoom_profile"

class PasswordsProfile < ZoomProfile
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
            @profile = AgProfile.new(nil, "-uS", "", @passwd_regex)
        elsif (
            ScoobyDoo.where_are_you("ack") ||
            ScoobyDoo.where_are_you("ack-grep")
        )
            @profile = AckProfile.new(
                nil,
                "--smart-case",
                "",
                @passwd_regex
            )
        else
            @profile = GrepProfile.new(
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
        @taggable = true
    end

    def to_s
        return @porfile.to_s
    end
end
