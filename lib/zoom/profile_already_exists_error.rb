require "zoom/error"

class Zoom::ProfileAlreadyExistsError < Zoom::Error
    def initialize(profile)
        super("Profile #{profile} already exists!")
    end
end
