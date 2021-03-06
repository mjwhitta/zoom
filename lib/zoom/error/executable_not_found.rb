class Zoom::Error::ExecutableNotFound < Zoom::Error
    def initialize(exe = nil)
        super("Executable not found: #{exe}") if (exe)
        super("Executable not found") if (exe.nil?)
    end
end
