require "zoom/profile_manager"

case Zoom::ProfileManager.default_profile
when /^ack(-grep)?$/
    class Zoom::Profile::Passwords < Zoom::Profile::Ack; end
when "ag"
    class Zoom::Profile::Passwords < Zoom::Profile::Ag; end
when "pt"
    class Zoom::Profile::Passwords < Zoom::Profile::Pt; end
when "grep"
    class Zoom::Profile::Passwords < Zoom::Profile::Grep; end
else
    # Shouldn't happen
end

class Zoom::Profile::Passwords
    def initialize(n, o = nil, f = "", b = "", a = "")
        op = Zoom::ProfileManager.default_profile
        after = "| \\grep -v \"^[^:]*test[^:]*:[0-9]+:\""

        case op
        when /^ack(-grep)?$/
            super(n, op, "--smart-case #{f}", "", after)
        when "ag"
            super(n, op, "-Su #{f}", "", after)
        when "pt"
            super(n, op, "-SU --hidden #{f}", "", after)
        when "grep"
            super(n, op, "-ai #{f}", "", after)
        else
            # Shouldn't happen
        end

        @pattern = "(key|pass(word|wd)?)[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
