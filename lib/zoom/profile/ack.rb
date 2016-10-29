class Zoom::Profile::Ack < Zoom::Profile
    def initialize(n, o = "ack", f = "--smart-case", b = "", a = "")
        # Special case because of debian
        if ((o == "ack") && ScoobyDoo.where_are_you("ack-grep"))
            o = "ack-grep"
        end

        super(n, o, f, b, a)
        @format_flags = [
            "-H",
            "--follow",
            "--nobreak",
            "--nocolor",
            "--noheading",
            "-s"
        ].join(" ")
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "ignore"
                to.push("--type-set=zoom:match:/#{value}/ --zoom")
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
