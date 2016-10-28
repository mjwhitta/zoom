require "hilighter"
require "json_config"
require "scoobydoo"

class Zoom::Config < JSONConfig
    def add_security_profiles
        profiles = get("profiles")
        Zoom::ProfileManager::security_profiles.each do |profile|
            profiles[profile.name] = profile
        end
        set("profiles", profiles)
    end

    def color(key, value)
        if (value)
            validate_color(value)
            set(key, value)
        end

        value = get(key)
        validate_color(value)
        return value
    end
    private :color

    def color_filename(clr = nil)
        return color("color_filename", clr)
    end
    private :color_filename

    def color_lineno(clr = nil)
        return color("color_lineno", clr)
    end
    private :color_lineno

    def color_match(clr = nil)
        return color("color_match", clr)
    end
    private :color_match

    def color_tag(clr = nil)
        return color("color_tag", clr)
    end
    private :color_tag

    def current_profile_name(name = nil)
        set("current_profile_name", name) if (name)
        return get("current_profile_name")
    end

    def default_config
        default = Zoom::ProfileManager.default_profile
        profiles = Zoom::ProfileManager.default_profiles

        clear
        set("color", true)
        set("color_filename", "green")
        set("color_lineno", "white")
        set("color_match", "black.on_white")
        set("color_tag", "red")
        set("current_profile_name", default)
        set("editor", "")
        set("profiles", profiles)
    end

    def editor(ed = nil)
        if (ed)
            e = ScoobyDoo.where_are_you(ed)
            raise Zoom::Error::ExecutableNotFound.new(ed) if (e.nil?)
            set("editor", ed)
        end

        e = get("editor")
        e = ENV["EDITOR"] if (e.nil? || e.empty?)
        e = "vim" if (e.nil? || e.empty?)
        e = ScoobyDoo.where_are_you(e)
        e = ScoobyDoo.where_are_you("vi") if (e.nil?)
        raise Zoom::Error::ExecutableNotFound.new("vi") if (e.nil?)

        return e
    end

    def has_profile?(name)
        return get("profiles").has_key?(name)
    end

    def hilight(flag = nil)
        set("color", flag) if (!flag.nil?)
        return get("color")
    end

    def hilight_filename(str)
        return str if (!hilight)
        color_filename.split(".").inject(str, :send)
    end

    def hilight_lineno(str)
        return str if (!hilight)
        color_lineno.split(".").inject(str, :send)
    end

    def hilight_match(str)
        return str if (!hilight)
        color_match.split(".").inject(str, :send)
    end

    def hilight_tag(str)
        return str if (!hilight)
        color_tag.split(".").inject(str, :send)
    end

    def initialize(file = nil)
        file ||= "~/.zoomrc"
        super(file)
    end

    def get_profile(name)
        return get_profiles(false)[name]
    end

    def get_profile_names
        return get("profiles").keys.sort do |a, b|
            a.downcase <=> b.downcase
        end
    end

    def get_profiles(display_error = true)
        profiles = Hash.new
        get("profiles").each do |name, prof|
            begin
                profiles[name] = Zoom::Profile.from_json(prof)
            rescue Zoom::Error => e
                puts e.message if (display_error)
            end
        end
        return profiles
    end

    def set_profiles(profiles)
        set("profiles", profiles)
    end

    def validate_color(clr)
        clr.split(".").each do |c|
            if (
                String.colors.keys.include?(c.gsub(/^on_/, "")) ||
                String.modes.keys.include?(c)
            )
                next
            end

            raise Zoom::Error::InvalidColor.new(clr)
        end
    end
    private :validate_color

    def validate_colors
        # Validate colors
        color_filename
        color_lineno
        color_match
        color_tag
    end
end
