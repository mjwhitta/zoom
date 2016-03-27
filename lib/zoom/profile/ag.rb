class Zoom::Profile::Ag < Zoom::Profile
    def initialize(n, o = "ag", f = "-S", b = "", a = "")
        super(n, o, f, b, a)
        @taggable = true
    end
end
