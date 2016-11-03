class Zoom::SecurityProfile::UnsafePython < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case --python"
        when "ag"
            flags = "-S -G \"\\.py$\""
        when "grep"
            flags = "-i --include=\"*.py\""
        when "pt"
            flags = "-S -G \"\\.py$\""
        end

        super(n, nil, flags, b, a)
        @pattern = [
            "(",
            [
                "c?[Pp]ickle\\.loads?",
                "eval",
                "exec",
                "os\\.(popen|system)",
                "subprocess\\.call",
                "yaml\\.load"
            ].join("|"),
            ")\\("
        ].join
        @taggable = true
    end
end
