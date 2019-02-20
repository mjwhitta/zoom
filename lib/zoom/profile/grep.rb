class Zoom::Profile::Grep < Zoom::Profile
    def grep_like_format_flags(all = false)
        super
        @format_flags = [
            "--color=never",
            "-#{"E" if (!flags.match(/-[^ -]*P/))}HInrs",
            "--exclude-dir=.bzr",
            "--exclude-dir=.git",
            "--exclude-dir=.git-crypt",
            "--exclude-dir=.svn"
        ].join(" ")
        @format_flags = "--color=never -aEHnRs" if (all)
        @taggable = true
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        f ||= "-iP"
        t ||= "grep"
        super(n, t, f, b, a)
    end

    def only_exts_and_files
        f = Array.new
        @exts.each do |ext|
            f.push("--include=\"*.#{ext}\"")
        end
        @files.each do |file|
            f.push("--include=\"#{file}\"")
        end
        return f.join(" ")
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "all"
                grep_like_format_flags(true)
            when "follow"
                to.push("-R")
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
