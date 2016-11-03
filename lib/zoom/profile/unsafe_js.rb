class Zoom::SecurityProfile::UnsafeJs < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --js"
        when "ag"
            f ||= "-S -G \"\\.js$\""
        when "grep"
            f ||= "-i --include=\"*.js\""
        when "pt"
            f ||= "-S -G \"\\.js$\""
        end

        super(n, nil, f, b, a)
        @pattern = "\\.((append|eval|html)\\(|innerHTML)"
        @taggable = true
    end
end
