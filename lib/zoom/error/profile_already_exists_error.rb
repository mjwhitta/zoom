require "zoom/error"

class Zoom::Error::ProfileAlreadyExistsError < Zoom::Error
    def initialize(profile = nil)
        super("Profile already exists: #{profile}") if (profile)
        super("Profile already exists") if (profile.nil?)
    end
end
