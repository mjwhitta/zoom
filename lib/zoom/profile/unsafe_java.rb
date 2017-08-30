class Zoom::SecurityProfile::UnsafeJava < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = ["java", "properties"]
        functions = [
            "\\.exec",
            "\\.getRuntime",
            "readObject",
            "Runtime"
        ]
        imports = "(sun\\.misc\\.)?Unsafe"
        @regex = [
            imports,
            "(#{functions.join("|")})\\(",
        ].join("|")
    end
end
