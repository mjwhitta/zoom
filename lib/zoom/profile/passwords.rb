class Zoom::SecurityProfile::Passwords < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case"
        when "ag"
            flags = "-Su"
        when "grep"
            flags = "-ai"
        when "pt"
            flags = "-SU --hidden"
        end

        super(n, nil, flags, b, a)
        @pattern = "(key|pass(wd|word)?)[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
