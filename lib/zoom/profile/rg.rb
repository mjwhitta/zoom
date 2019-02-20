class Zoom::Profile::Rg < Zoom::Profile
    def grep_like_format_flags(all = false)
        super
        @format_flags = [
            "--color never",
            "-H",
            "-n",
            "--no-heading",
            "--no-messages"
        ].join(" ")
        @format_flags = "#{@format_flags} -uuu" if (all)
        @taggable = true
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        f ||= "-PS"
        t ||= "rg"
        super(n, t, f, b, a)
    end

    def only_exts_and_files
        f = Array.new
        @exts.each do |ext|
            f.push("--type-add \"zoom:*.#{ext}\"")
        end
        @files.each do |file|
            f.push("--type-add \"zoom:#{file}\"")
        end
        f.push("-t zoom") if (!@exts.empty? || !@files.empty?)
        return f.join(" ")
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "all"
                grep_like_format_flags(true)
            when "follow"
                to.push("--follow")
            when "ignore"
                value.each do |v|
                    to.push("--iglob=\"!#{v}\"")
                end
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
