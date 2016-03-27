class Zoom::Profile::Find < Zoom::Profile
    def initialize(n, o = "find", f = ". -name", b = "", a = "")
        super(n, o, f, b, a)
        @taggable = true
    end
end
