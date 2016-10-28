require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::UnsafePython < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        # I don't care about test code
        after = "| \\grep -v \"^[^:]*test[^:]*:[0-9]+:\""
        flags = ""

        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case --python"
        when "ag"
            flags = "-S -G \"\\.py$\""
        when "pt"
            flags = "-S -G \"\\.py$\""
        when "grep"
            flags = "-i --include=\"*.py\""
        end

        super(n, op, flags, "", after)
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
