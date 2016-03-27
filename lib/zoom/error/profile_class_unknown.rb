class Zoom::Error::ProfileClassUnknown < Zoom::Error
    def initialize(clas = nil)
        super("Profile class unknown: #{clas}") if (clas)
        super("Profile class unknown") if (clas.nil?)
    end
end
