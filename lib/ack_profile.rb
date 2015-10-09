require "shellwords"
require "zoom_profile"

class AckProfile < ZoomProfile
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
        operator = nil
        if (ScoobyDoo.where_are_you("ack"))
            operator = "ack"
        elsif (ScoobyDoo.where_are_you("ack-grep"))
            operator = "ack-grep"
        else
            # Oops
            operator = "echo"
            if (operator == "echo")
                flags = "#"
                envprepend = ""
                append = ""
            end
        end

        super(operator, flags, envprepend, append)
        @taggable = true
    end
end
