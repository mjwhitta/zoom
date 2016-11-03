clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::SecurityProfile < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        super(n, Zoom::ProfileManager.default_profile, f, b, a)
    end
end
