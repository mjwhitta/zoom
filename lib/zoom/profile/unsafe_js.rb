class Zoom::SecurityProfile::UnsafeJs < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = ["js", "jsx", "vue"]
        @regex = [
            "\\.",
            "(",
            [
                "(append|eval|html)\\(",
                "innerHTML"
            ].join("|"),
            ")"
        ].join
    end
end
