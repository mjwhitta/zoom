class Zoom::Profile::Ack < Zoom::Profile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        # Special case because of debian
        o ||= "ack"
        if ((o == "ack") && ScoobyDoo.where_are_you("ack-grep"))
            o = "ack-grep"
        end

        f ||= "--smart-case"
        super(n, o, f, b, a)
        @format_flags = [
            "--follow",
            "-H",
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
                value.each do |v|
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
