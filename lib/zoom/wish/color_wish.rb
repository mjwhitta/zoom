require "djinni"

class ColorWish < Djinni::Wish
    def aliases
        return ["color"]
    end

    def description
        return "Configure colors"
    end

    def execute(args, djinni_env = {})
        f, found, c = args.rpartition(" ")
        if (f.include?(" "))
            usage
            return
        end

        config = djinni_env["config"]

        if (found.empty?)
            f = c

            case f
            when "off"
                config.no_hilight
            when "on"
                config.hilight
            else
                usage
            end

            return
        end

        case f
        when "off", "on"
            usage
        else
            c.split(".").each do |color|
                if (!@colors.include?(color))
                    puts("Invalid color: #{color}")
                    return
                end
            end

            config.send("set_color_#{f}", c)
        end
    end

    def initialize
        @colors = [
            "black",
            "blue",
            "cyan",
            "default",
            "green",
            "magenta",
            "red",
            "white",
            "yellow",
            "light_black",
            "light_blue",
            "light_cyan",
            "light_green",
            "light_magenta",
            "light_red",
            "light_white",
            "light_yellow",
            "on_black",
            "on_blue",
            "on_cyan",
            "on_green",
            "on_magenta",
            "on_red",
            "on_white",
            "on_yellow",
            "on_light_black",
            "on_light_blue",
            "on_light_cyan",
            "on_light_green",
            "on_light_magenta",
            "on_light_red",
            "on_light_white",
            "on_light_yellow"
        ]
        @fields = {
            "filename" => "Configure filename color (default: green)",
            "lineno" =>
                "Configure line number color (default: white)",
            "match" =>
                "Configure match color (default: black.on_white)",
            "off" => "Turn off colorized output",
            "on" => "Turn on colorized output (default)",
            "tag" => "Configure tag color (default: red)"
        }
    end

    def tab_complete(input, djinni_env = {})
        f, found, c = input.rpartition(" ")

        return [{}, "", ""] if (f.include?(" "))

        if (found.empty?)
            f = c

            completions = @fields.select do |field, desc|
                field.downcase.start_with?(f.downcase)
            end

            append = " "
            append = "" if (f.start_with?("o"))
            return [completions, f, append]
        else
            case f
            when "off", "on"
                return [{}, "", ""]
            else
                last = c.rpartition(".")[-1]

                completions = Hash.new
                @colors.select do |color|
                    color.downcase.start_with?(last.downcase)
                end.each do |color|
                    completions[color] = ""
                end

                return [completions, last, ""]
            end
        end
    end

    def usage
        puts("#{aliases.join(", ")} <field> [color]")
        puts("    #{description}.")
        puts
        puts("FIELDS")
        @fields.each do |field, desc|
            puts("    #{field}")
        end
        puts
        puts("COLORS")
        @colors.each do |color|
            puts("    #{color}")
        end
    end
end
