require "zoom/error"

class Zoom::Error::ProfileAlreadyExistsError < Zoom::Error
    def initialize(profile)
        super("Profile #{profile} already exists!")
    end
end
