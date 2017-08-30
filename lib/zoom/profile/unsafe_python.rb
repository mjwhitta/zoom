class Zoom::SecurityProfile::UnsafePython < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = ["py"]
        functions = [
            "c?[Pp]ickle\\.loads?",
            "eval",
            "exec",
            "os\\.(popen|system)",
            "subprocess\\.call",
            "yaml\\.load"
        ]
        start_or_not_variable = "(^|[^\\nA-Za-z_])"
        @regex = [
            start_or_not_variable,
            "(#{functions.join("|")})\\(",
        ].join
    end
end
