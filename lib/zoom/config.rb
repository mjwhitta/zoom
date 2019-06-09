require "hilighter"
require "json_config"
require "scoobydoo"

class Zoom::Config < JSONConfig
    extend JSONConfig::Keys

    add_bool_key("hilight")
    add_key("color_filename")
    add_key("color_lineno")
    add_key("color_match")
    add_key("color_tag")
    add_key("current_profile_name")
    add_key("editor")
    add_key("profiles")

    def add_security_profiles
        profiles = parse_profiles
        Zoom::ProfileManager::security_profiles.each do |profile|
            profiles[profile.name] = profile
        end
        set_profiles(profiles)
    end

    def has_profile?(name)
        return profiles? && get_profiles.has_key?(name)
    end

    def hilight_filename(str)
        return str if (!hilight?)
        get_color_filename.split(".").inject(str, :send)
    end

    def hilight_lineno(str)
        return str if (!hilight?)
        get_color_lineno.split(".").inject(str, :send)
    end

    def hilight_match(str)
        return str if (!hilight?)
        get_color_match.split(".").inject(str, :send)
    end

    def hilight_tag(str)
        return str if (!hilight?)
        get_color_tag.split(".").inject(str, :send)
    end

    def initialize(file = nil)
        file ||= "~/.config/zoom/rc"
        defaultprof = Zoom::ProfileManager.default_tool
        profiles = Zoom::ProfileManager.default_profiles
        @defaults = {
            "color_filename" => "green",
            "color_lineno" => "white",
            "color_match" => "black.on_white",
            "color_tag" => "red",
            "current_profile_name" => defaultprof,
            "editor" => nil,
            "hilight" => true,
            "profiles" => profiles
        }
        super(file)
    end

    def get_profile(name)
        return parse_profiles(false)[name]
    end

    def get_profile_names
        return get_profiles.keys.sort do |a, b|
            a.downcase <=> b.downcase
        end
    end

    def parse_profiles(display_error = true)
        profiles = Hash.new
        get_profiles.each do |name, prof|
            begin
                profiles[name] = Zoom::Profile.from_json(prof)
            rescue Zoom::Error => e
                puts(e.message) if (display_error)
            end
        end
        return profiles
    end

    def use_editor(editor)
        if (editor && !editor.empty?)
            ed, _, _ = editor.partition(" ")
            if (ScoobyDoo.where_are_you(ed).nil?)
                raise Zoom::Error::ExecutableNotFound.new(ed)
            end
        end
        set_editor(editor)
    end

    def validate_color(clr)
        @valid ||= String.colors.keys.concat(String.modes.keys)
        clr.split(".").each do |c|
            next if (@valid.include?(c.gsub(/^on_/, "")))
            raise Zoom::Error::InvalidColor.new(clr)
        end
    end
    private :validate_color

    def validate_colors
        # Validate colors
        validate_color(get_color_filename)
        validate_color(get_color_lineno)
        validate_color(get_color_match)
        validate_color(get_color_tag)
    end
end
