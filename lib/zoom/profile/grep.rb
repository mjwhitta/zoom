class Zoom::Profile::Grep < Zoom::Profile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        f ||= "-i"
        o ||= "grep"
        super(n, o, f, b, a)
        @format_flags = [
            "--color=never",
            "-EHInRs",
            "--exclude-dir=.bzr",
            "--exclude-dir=.git",
            "--exclude-dir=.git-crypt",
            "--exclude-dir=.svn"
        ].join(" ")
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "ignore"
                value.each do |v|
                    to.push("--exclude=#{v} --exclude-dir=#{v}")
                end
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
