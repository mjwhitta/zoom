class Zoom::SecurityProfile::UnsafeRuby < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case --ruby"
        when "ag"
            flags = [
                "-S",
                "-G \"\\.(erb|r(ake|b|html|js|xml)|spec)$|Rakefile\""
            ].join(" ")
        when "grep"
            flags = [
                "-i",
                "--include=\"*.erb\"",
                "--include=\"*.rake\"",
                "--include=\"*.rb\"",
                "--include=\"*.rhtml\"",
                "--include=\"*.rjs\"",
                "--include=\"*.rxml\"",
                "--include=\"*.spec\"",
                "--include=\"Rakefile\""
            ].join(" ")
        when "pt"
            flags = [
                "-S",
                "-G \"\\.(erb|r(ake|b|html|js|xml)|spec)$|Rakefile\""
            ].join(" ")
        end

        super(n, nil, flags, b, a)
        @pattern = [
            "%x\\(",
            "\\.constantize",
            "instance_eval",
            "(public_)?send",
            "system"
        ].join("|")
        @taggable = true
    end
end
