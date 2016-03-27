class Zoom::Error::InvalidColor < Zoom::Error
    def initialize(color)
        super("Invalid color: #{color}")
    end
end
