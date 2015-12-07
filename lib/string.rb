# Redefine String class to allow for colorizing, rsplit, and word wrap
class String
    def black
        return colorize(30)
    end

    def blue
        return colorize(34)
    end

    def colorize(color)
        return "\e[#{color}m#{self}\e[0m"
    end

    def cyan
        return colorise(36)
    end

    def green
        return colorize(32)
    end

    def purple
        return colorize(35)
    end

    def red
        return colorize(31)
    end

    def rsplit(pattern)
        ret = rpartition(pattern)
        ret.delete_at(1)
        return ret
    end

    def white
        return colorize(37)
    end

    def word_wrap(width = 70)
        return scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/).join("\n")
    end

    def yellow
        return colorize(33)
    end
end
