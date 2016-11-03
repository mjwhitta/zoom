class Zoom::Profile::Find < Zoom::Profile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        f ||= ""
        o ||= "find"
        super(n, o, f, b, a)
        @taggable = true
    end
end
