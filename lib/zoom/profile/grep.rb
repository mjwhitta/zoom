class Zoom::Profile::Grep < Zoom::Profile
    def initialize(n, o = "grep", f = "-i", b = "", a = "")
        super(n, o, f, b, a)
        @taggable = true
    end
end
