class Zoom::Profile::Pt < Zoom::Profile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        f ||= "-S"
        o ||= "pt"
        super(n, o, f, b, a)
        @format_flags = "-e -f --nocolor --nogroup"
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
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
