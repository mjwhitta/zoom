require "zoom/error"

class Zoom::Error::ExecutableNotFoundError < Zoom::Error
    def initialize(exe)
        super("Executable #{exe} not found!")
    end
end
