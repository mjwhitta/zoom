class Zoom::SecurityProfile::UnsafeJava < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --java"
        when "ag"
            f ||= "-S -G \"\\.(java|properties)$\""
        when "grep"
            f ||= [
                "-i",
                "--include=\"*.java\"",
                "--include=\"*.properties\""
            ].join(" ")
        when "pt"
            f ||= "-S -G \"\\.(java|properties)$\""
        end

        super(n, nil, f, b, a)
        @pattern = [
            "(sun\\.misc\\.)?Unsafe",
            "(\\.getRuntime|readObject|Runtime)\\("
        ].join("|")
        @taggable = true
    end
end
