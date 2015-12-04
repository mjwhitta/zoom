require "zoom/error"

class Zoom::Error::ProfileDoesNotExistError < Zoom::Error
    def initialize(profile = nil)
        super("Profile does not exist: #{profile}") if (profile)
        super("Profile does not exist") if (profile.nil?)
    end
end
