class Zoom::SecurityProfile::Passwords < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        super(n, t, f, b, a)
        # Don't search binary files
        # grep_like_format_flags(true)
        @regex = "(key|pa?ss(w(o?r)?d)?)[^:=,>]? *[:=,>]"
    end
end
