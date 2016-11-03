class Zoom::SecurityProfile::UnsafeC < Zoom::SecurityProfile
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            flags = "--smart-case --cc --cpp"
        when "ag"
            flags = "-S -G \"\\.(c|h)(pp)?$\""
        when "grep"
            flags = "-i --include=\"*.[ch]\" --include=\"*.[ch]pp\""
        when "pt"
            flags = "-S -G \"\\.(c|h)(pp)?$\""
        end

        super(n, nil, flags, b, a)
        @pattern = [
            "(",
            [
                "_splitpath",
                "ato[fil]",
                "gets",
                "makepath",
                "(sn?)?scanf",
                "str(cat|cpy|len)",
                "v?sprintf"
            ].join("|"),
            ")",
            "\\("
        ].join
        @taggable = true
    end
end
