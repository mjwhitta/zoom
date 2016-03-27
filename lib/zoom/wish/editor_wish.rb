require "djinni"
require "scoobydoo"

class EditorWish < Djinni::Wish
    def aliases
        return ["editor"]
    end

    def description
        return "Configure editor"
    end

    def execute(args, djinni_env = {})
        if (args.include?(" "))
            usage
            return
        end

        config = djinni_env["config"]
        if (ScoobyDoo.where_are_you(args))
            config.editor(args)
        else
            puts "Editor not found: #{args}"
        end
    end

    def usage
        puts "#{aliases.join(", ")} <value>"
        puts "    #{description}."
    end
end
