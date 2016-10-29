require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::Passwords < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case"
        when "ag"
            flags = "-Su"
        when "pt"
            flags = "-SU --hidden"
        when "grep"
            flags = "-ai"
        end

        super(n, op, flags)
        @pattern = "(key|pass(wd|word)?)[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
