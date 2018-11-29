require "pathname"

class Zoom::Profile::Find < Zoom::Profile
    def exe(header)
        cmd = [
            before,
            tool,
            header["paths"],
            flags,
            header["translated"],
            header["args"],
            header["regex"],
            after
        ].join(" ").strip

        if (header.has_key?("debug") && header["debug"])
            puts cmd
            return ""
        else
            return %x(#{cmd})
        end
    end

    def grep_like_format_flags(all = false)
        super
        @taggable = true
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        a = "-print" if (a.nil? || a.empty?)
        f ||= ""
        t ||= "find"
        super(n, t, f, b, a)
    end

    def preprocess(header)
        # If additional args are passed, then assume regex is actually
        # an arg
        if (!header["args"].empty?)
            header["args"] += " #{header["regex"]}"
            header["regex"] = ""
        end

        # If regex was provided then assume it's an iname search
        if (!header["regex"].empty?)
            header["regex"] = "-iregex \"#{header["regex"]}\""
        end

        return header
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "follow"
                to.push("-L")
            when "ignore"
                value.each do |v|
                    to.push("-name \"#{v}\" -prune -o")
                end
            end
        end
        return to.join(" ")
    end
end
