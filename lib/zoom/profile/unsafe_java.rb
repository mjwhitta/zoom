class Zoom::SecurityProfile::UnsafeJava < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case --java"
        when "ag"
            flags = "-S -G \"\\.(java|properties)$\""
        when "grep"
            flags = [
                "-i",
                "--include=\"*.java\"",
                "--include=\"*.properties\""
            ].join(" ")
        when "pt"
            flags = "-S -G \"\\.(java|properties)$\""
        end

        super(n, nil, flags, b, a)
        @pattern = [
            "(sun\\.misc\\.)?Unsafe",
            "(\\.getRuntime|readObject|Runtime)\\("
        ].join("|")
        @taggable = true
    end
end
