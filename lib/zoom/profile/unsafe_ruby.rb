class Zoom::SecurityProfile::UnsafeRuby < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --ruby"
        when "ag"
            f ||= [
                "-S",
                "-G \"\\.(erb|r(ake|b|html|js|xml)|spec)$|Rakefile\""
            ].join(" ")
        when "grep"
            f ||= [
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
            f ||= [
                "-S",
                "-G \"\\.(erb|r(ake|b|html|js|xml)|spec)$|Rakefile\""
            ].join(" ")
        end

        super(n, nil, f, b, a)
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
