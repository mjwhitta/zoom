class Zoom::SecurityProfile::Passwords < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case"
        when "ag"
            f ||= "-Su"
        when "grep"
            f ||= "-ai"
        when "pt"
            f ||= "-SU --hidden"
        end

        super(n, nil, f, b, a)
        @pattern = "(key|pass(wd|word)?)[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
