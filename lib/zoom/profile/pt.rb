require "shellwords"
require "zoom/profile"

class Zoom::Profile::Pt < Zoom::Profile
    def exe(args, pattern)
        # Emulate ag/ack as much as possible
        if (pattern.nil? || pattern.empty?)
            system(
                "#{self.to_s} #{args} #{self.append} | " \
                "sed \"s|\\[K[:-]|\\[K\\n|\" | #{@pager}"
            )
        else
            system(
                "#{self.to_s} #{args} #{pattern.shellescape} " \
                "#{self.append} | sed \"s|\\[K[:-]|\\[K\\n|\" | " \
                "#{@pager}"
            )
        end
    end

    def initialize(
        operator = nil,
        flags = "--color -Se",
        envprepend = "",
        append = ""
    )
        super("pt", flags, envprepend, append)
        @taggable = true
    end
end
