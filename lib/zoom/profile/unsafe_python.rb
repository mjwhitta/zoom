class Zoom::SecurityProfile::UnsafePython < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --python"
        when "ag", "pt"
            f ||= "-S -G \"\\.py$\""
        when "grep"
            f ||= "-i --include=\"*.py\""
        end

        super(n, nil, f, b, a)
        @pattern = [
            "(^|[^\\nA-Za-z_])",
            "(",
            [
                "c?[Pp]ickle\\.loads?",
                "eval",
                "exec",
                "os\\.(popen|system)",
                "subprocess\\.call",
                "yaml\\.load"
            ].join("|"),
            ")",
            "\\("
        ].join
        @taggable = true
    end
end
