class Zoom::SecurityProfile::UnsafeJs < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case --js"
        when "ag"
            flags = "-S -G \"\\.js$\""
        when "grep"
            flags = "-i --include=\"*.js\""
        when "pt"
            flags = "-S -G \"\\.js$\""
        end

        super(n, nil, flags, b, a)
        @pattern = "\\.((append|eval|html)\\(|innerHTML)"
        @taggable = true
    end
end
