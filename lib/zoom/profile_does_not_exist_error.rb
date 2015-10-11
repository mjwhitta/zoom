require "zoom/error"

class Zoom::ProfileDoesNotExistError < Zoom::Error
    def initialize(profile)
        super("Profile #{profile} does not exist!")
    end
end
