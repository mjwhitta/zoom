class Zoom::SecurityProfile::Passwords < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case"
        when "ag", "pt"
            f ||= "-SU --hidden"
        when "grep"
            f ||= "-ai"
        end

        super(n, nil, f, b, a)
        @pattern = "(key|pa?ss(w(o?r)?d)?)[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
