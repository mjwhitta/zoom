clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::SecurityProfile < superclass
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        super(n, Zoom::ProfileManager.default_profile, f, b, a)
    end
end
