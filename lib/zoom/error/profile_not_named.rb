require "json"

class Zoom::Error::ProfileNotNamed < Zoom::Error
    def initialize(json)
        super("Profile has no name:\n#{JSON.pretty_generate(json)}")
    end
end
