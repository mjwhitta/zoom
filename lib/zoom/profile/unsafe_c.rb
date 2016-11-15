class Zoom::SecurityProfile::UnsafeC < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --cc --cpp"
        when "ag", "pt"
            f ||= "-S -G \"\\.(c|h)(pp)?$\""
        when "grep"
            f ||= "-i --include=\"*.[ch]\" --include=\"*.[ch]pp\""
        end

        super(n, nil, f, b, a)
        @pattern = [
            "(^|[^\\nA-Za-z_])",
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
