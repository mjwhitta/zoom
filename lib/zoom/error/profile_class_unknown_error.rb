require "zoom/error"

class Zoom::Error::ProfileClassUnknownError < Zoom::Error
    def initialize(clas = nil)
        super("Profile class unknown: #{clas}") if (clas)
        super("Profile class unknown") if (clas.nil?)
    end
end
