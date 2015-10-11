require "shellwords"
require "zoom/profile"

class Zoom::Profile::Find < Zoom::Profile
    def exe(args, pattern)
        if (pattern.nil? || pattern.empty?)
            system(
                "#{self.to_s} #{args} \"*\" #{self.append} | " \
                "#{@pager}"
            )
        else
            system(
                "#{self.to_s} #{args} \"#{pattern}\" " \
                "#{self.append} | #{@pager}"
            )
        end
    end

    def initialize(
        operator = nil,
        flags = ". -name",
        envprepend = "",
        append = ""
    )
        super("find", flags, envprepend, append)
        @taggable = true
    end
end
