require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::UnsafeJava < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case --java"
        when "ag"
            flags = "-S -G \"\\.(java|properties)$\""
        when "pt"
            flags = "-S -G \"\\.(java|properties)$\""
        when "grep"
            flags = [
                "-i",
                "--include=\"*.java\"",
                "--include=\"*.properties\""
            ].join(" ")
        end

        super(n, op, flags, b, a)
        @pattern = [
            "(sun\\.misc\\.)?Unsafe",
            "(\\.getRuntime|readObject|Runtime)\\("
        ].join("|")
        @taggable = true
    end
end
