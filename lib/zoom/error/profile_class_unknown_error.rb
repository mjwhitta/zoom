require "zoom/error"

class Zoom::Error::ProfileClassUnknownError < Zoom::Error
    def initialize(clas)
        super("Profile class #{clas} unknown!")
    end
end
