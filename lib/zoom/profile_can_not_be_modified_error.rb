require "zoom/error"

class Zoom::ProfileCanNotBeModifiedError < Zoom::Error
    def initialize(profile)
        super("Profile #{profile} can not be modified!")
    end
end
