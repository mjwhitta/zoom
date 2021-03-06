class Zoom::Profile::Pt < Zoom::Profile
    def grep_like_format_flags(all = false)
        super
        @format_flags = "-e --nocolor --nogroup --numbers"
        @format_flags = "#{@format_flags} --hidden -U" if (all)
        @taggable = true
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        f ||= "-S"
        t ||= "pt"
        super(n, t, f, b, a)
    end

    def only_exts_and_files
        if (!@exts.empty? || !@files.empty?)
            return "-G \"\.(#{@exts.join("|")})$|#{@files.join("|")}\""
        end
        return ""
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
                    to.push("--ignore=#{v}")
                end
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
