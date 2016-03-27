class Zoom::Profile::Grep < Zoom::Profile
    def initialize(n, o = "grep", f = "-Ii", b = "", a = ".")
        super(n, o, f, b, a)
        @taggable = true
    end
end
