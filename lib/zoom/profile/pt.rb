class Zoom::Profile::Pt < Zoom::Profile
    def initialize(n, o = "pt", f = "-S", b = "", a = "")
        super(n, o, f, b, a)
        @format_flags = "-e --nocolor --nogroup"
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
