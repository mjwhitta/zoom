require "shellwords"
require "zoom_profile"

class AgProfile < ZoomProfile
    def colors
        '--color-match "47;1;30" --color-line-number "0;37"'
    end

    def exe(args, pattern)
        if (pattern.nil? || pattern.empty?)
            system(
                "#{self.to_s} --pager \"#{@pager}\" #{args} " \
                "#{self.append}"
            )
        else
            system(
                "#{self.to_s} --pager \"#{@pager}\" #{args} " \
                "#{pattern.shellescape} #{self.append}"
            )
        end
    end

    def initialize(
        operator = nil,
        flags = "-S",
        envprepend = "",
        append = ""
    )
        super("ag", flags, envprepend, append)
        @taggable = true
    end

    def to_s
        [
            self["prepend"],
            self["operator"],
            self.colors,
            self["flags"]
        ].join(" ").strip
    end
end
