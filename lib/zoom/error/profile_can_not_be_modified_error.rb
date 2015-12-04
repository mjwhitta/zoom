require "zoom/error"

class Zoom::Error::ProfileCanNotBeModifiedError < Zoom::Error
    def initialize(profile = nil)
        super("Profile can not be modified: #{profile}") if (profile)
        super("Profile can not be modified") if (profile.nil?)
    end
end
