require "djinni"

class ResetWish < Djinni::Wish
    def aliases
        return ["default", "reset"]
    end

    def description
        return "Create default profiles"
    end

    def execute(args, djinni_env = {})
        if (!args.empty?)
            usage
            return
        end

        FileUtils.rm_f(Pathname.new("~/.zoomrc").expand_path)
        config = djinni_env["config"]
        config.default

        cache = djinni_env["cache"]
        cache.clear

        # Update prompt
        default = config.get_current_profile_name
        prompt_color = djinni_env["prompt_color"]
        if (prompt_color)
            prompt = "zoom(#{default})> ".send(prompt_color)
        else
            prompt = "zoom(#{default})> "
        end
        djinni_env["djinni_prompt"] = prompt
    end

    def usage
        puts "#{aliases.join(", ")}"
        puts "    #{description}."
    end
end
