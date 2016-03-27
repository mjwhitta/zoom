require "zoom/profile_manager"

case Zoom::ProfileManager.default_profile
when /^ack(-grep)?$/
    class Zoom::Profile::Passwords < Zoom::Profile::Ack
    end
when "ag"
    class Zoom::Profile::Passwords < Zoom::Profile::Ag
    end
when "pt"
    class Zoom::Profile::Passwords < Zoom::Profile::Pt
    end
else
    class Zoom::Profile::Passwords < Zoom::Profile::Grep
    end
end

class Zoom::Profile::Passwords
    def initialize(n, o = nil, f = "", b = "", a = "")
        op = Zoom::ProfileManager.default_profile

        case op
        when /^ack(-grep)?$/
            super(
                n,
                op,
                "--smart-case --ignore-dir=test --ignore-dir=tests"
            )
        when "ag"
            super(n, op, "-Su --ignore=\"\/*test*\/\"")
        when "pt"
            super(n, op, "-SU --hidden --ignore=\"\/*test*\/\"")
        else
            super(n, op, "-ai --exclude-dir=test --exclude-dir=tests")
        end

        @pattern = "pass(word|wd)?[^:=,>]? *[:=,>]"
        @taggable = true
    end
end
