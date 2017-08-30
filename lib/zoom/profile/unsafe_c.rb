class Zoom::SecurityProfile::UnsafeC < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = [
            "C",
            "c",
            "cc",
            "cpp",
            "cxx",
            "H",
            "h",
            "hh",
            "hpp",
            "hxx",
            "m",
            "tpp",
            "xs"
        ]
        functions = [
            "_splitpath",
            "ato[fil]",
            "gets",
            "makepath",
            "popen",
            "(sn?)?scanf",
            "str(cat|cpy|len)",
            "v?sprintf"
        ]
        start_or_not_variable = "(^|[^\\nA-Za-z_])"
        @regex = [
            start_or_not_variable,
            "(#{functions.join("|")})\\(",
        ].join
    end
end
