require "zoom/error"

class Zoom::Error::ProfileDoesNotExistError < Zoom::Error
    def initialize(profile)
        super("Profile #{profile} does not exist!")
    end
end
