require "shellwords"
require "zoom_profile"

class GrepProfile < ZoomProfile
    def colors
        [
            'GREP_COLORS="',
            "fn=1;32:",
            "ln=0;37:",
            "ms=47;1;30:",
            "mc=47;1;30:",
            "sl=:cx=:bn=:se=",
            '"'
        ].join.strip
    end

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
        flags = [
            "--color=always",
            "-EHIinR",
            "--exclude-dir=.bzr",
            "--exclude-dir=.git",
            "--exclude-dir=.svn"
        ].join(" ").strip,
        envprepend = "",
        append = "."
    )
        super("grep", flags, envprepend, append)
        @taggable = true
    end
end
