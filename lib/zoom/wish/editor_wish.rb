require "djinni"

class EditorWish < Djinni::Wish
    def aliases
        return ["editor"]
    end

    def description
        return "Configure editor"
    end

    def execute(args, djinni_env = {})
        if (args.empty?)
            usage
            return
        end

        djinni_env["config"].editor(args)
    end

    def usage
        puts "#{aliases.join(", ")} <value>"
        puts "    #{description}."
    end
end
