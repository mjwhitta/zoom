class Zoom::Profile::Ag < Zoom::Profile
    def initialize(n, o = "ag", f = "-S", b = "", a = "")
        super(n, o, f, b, a)
        @format_flags = [
            "--filename",
            "--nobreak",
            "--nocolor",
            "--noheading",
            "--silent"
        ].join(" ")
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "ignore"
                to.push("--ignore=#{value}")
            when "word-regexp"
                to.push("-w")
            end
        end
        return to.join(" ")
    end
end
