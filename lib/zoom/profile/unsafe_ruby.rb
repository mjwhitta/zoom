class Zoom::SecurityProfile::UnsafeRuby < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = [
            "erb",
            "gemspec",
            "irbrc",
            "rake",
            "rb",
            "rhtml",
            "rjs",
            "rxml",
            "spec"
        ]
        @files = ["Gemfile", "Rakefile"]
        @regex = [
            "%x\\(",
            "|",
            "\\.constantize",
            "|",
            "(^|[^\\nA-Za-z_])",
            "(",
            [
                "instance_eval",
                "(public_)?send",
                "system",
            ].join("|"),
            ")"
        ].join
    end
end
