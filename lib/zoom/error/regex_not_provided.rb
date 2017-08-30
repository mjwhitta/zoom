class Zoom::Error::RegexNotProvided < Zoom::Error
    def initialize
        super("A regex was not provided or hard-coded")
    end
end
