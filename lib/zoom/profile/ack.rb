class Zoom::Profile::Ack < Zoom::Profile
    def grep_like_format_flags(all = false)
        super
        @format_flags = [
            "-H",
            "--nobreak",
            "--nocolor",
            "--nogroup",
            "--noheading",
            "-s"
        ].join(" ")
        @taggable = true
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        f ||= "--smart-case"

        # Special case because of debian
        t ||= "ack"
        if ((t == "ack") && ScoobyDoo.where_are_you("ack-grep"))
            t = "ack-grep"
        end

        super(n, t, f, b, a)
    end

    def only_exts
        f = Array.new
        @exts.each do |ext|
            f.push("--type-add \"zoom:ext:#{ext}\"")
        end
        @files.each do |file|
            f.push("--type-add \"zoom:is:#{file}\"")
        end
        f.push("--type zoom") if (!@exts.empty? || !@files.empty?)
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
                    # Convert GLOB to regex
                    v.gsub!(/\./, "\\.")
                    v.gsub!(/\*/, ".*")

                    to.push("--ignore-dir=\"#{v}\"")
                    to.push("--ignore-file=\"match:/#{v}/\"")
                end
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
