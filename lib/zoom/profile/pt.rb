class Zoom::Profile::Pt < Zoom::Profile
    def initialize(n, o = "pt", f = "-S", b = "", a = "")
        super(n, o, f, b, a)
        @taggable = true
    end
end
