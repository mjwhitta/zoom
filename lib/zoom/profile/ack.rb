require "shellwords"
require "zoom/profile"

class Zoom::Profile::Ack < Zoom::Profile
    def colors
        'ACK_COLOR_LINENO=white ACK_COLOR_MATCH="black on_white"'
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
        flags = "--smart-case",
        envprepend = "",
        append = ""
    )
        # Special case because of debian
        operator = "ack"
        operator = "ack-grep" if (ScoobyDoo.where_are_you("ack-grep"))

        super(operator, flags, envprepend, append)
        @taggable = true
    end
end
