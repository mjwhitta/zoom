require "zoom/error"

class Zoom::ProfileClassUnknownError < Zoom::Error
    def initialize(clas)
        super("Profile class Zoom::#{clas} unknown!")
    end
end
