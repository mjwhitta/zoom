require "fagin"
require "pathname"

class Zoom
    attr_reader :cache
    attr_reader :config

    def ensure_valid_header(header)
        # Ensure header has no nil
        header["args"] ||= ""
        header["debug"] ||= false
        header["paths"] ||= "."
        header["paths"] = "." if (header["paths"].empty?)
        header["profile_name"] ||= ""
        header["pwd"] = Dir.pwd
        header["regex"] ||= ""
        header["translate"] ||= Hash.new

        # If no profile name, use the current profile
        profile_name = header["profile_name"]
        if (profile_name.empty?)
            profile_name = @config.current_profile_name
            header["profile_name"] = profile_name
        end

        if (!@config.has_profile?(profile_name))
            raise Zoom::Error::ProfileDoesNotExist.new(profile_name)
        end

        profile = @config.get_profile(profile_name)

        # Use hard-coded regex if defined
        if (
            profile.regex &&
            !profile.regex.empty? &&
            (header["regex"] != profile.regex)
        )
            # If there was a regex then it may be an arg or a path
            if (!header["regex"].empty?)
                if (Pathname.new(header["regex"]).exist?)
                    header["paths"] = "" if (header["paths"] == ".")
                    paths = header["paths"].split(" ")
                    paths.insert(0, header["regex"])
                    header["paths"] = paths.join(" ")
                else
                    header["args"] += " #{header["regex"]}"
                end
            end

            header["regex"] = profile.regex
        end

        # If using a search tool
        if (!profile.format_flags.empty?)
            if (header["regex"].empty? && header["paths"] == ".")
                # Throw exception because no regex was provided or
                # hard-coded
                raise Zoom::Error::RegexNotProvided.new
            end

            # This isn't done here anymore as it breaks stuff
            # header["regex"] = header["regex"].shellescape
        end

        # Strip values
        header.keys.each do |key|
            next if (key == "regex")
            begin
                header[key].strip!
            rescue
                # Wasn't a String
            end
        end

        return header
    end
    private :ensure_valid_header

    def self.hilight(hilight = true)
        @@hilight = hilight
    end

    def self.hilight?
        @@hilight ||= false
        return @@hilight
    end

    def initialize(cache = nil, rc = nil)
        @cache = Zoom::Cache.new(cache)
        @config = Zoom::Config.new(rc)
        @@hilight = @config.hilight
    end

    def open(results)
        return if (results.nil? || results.empty?)
        Zoom::Editor.new(@config.editor).open(results)
    end

    def repeat(shortcut = true)
        return if (@cache.empty?)
        run(@cache.header, shortcut, true)
    end

    def run(h, shortcut = true, repeat = false)
        # Don't change the header passed in
        header = h.clone

        # Ensure header is formatted properly and valid
        header = ensure_valid_header(header) if (!repeat)

        profile_name = header["profile_name"]
        profile = @config.get_profile(profile_name)

        begin
            # Clear cache
            @cache.clear

            # Store needed details
            @cache.header(header)

            # Translate any needed flags
            header["translated"] = profile.translate(
                header["translate"]
            ).strip

            # This may append args such that the output will be
            # something Zoom can process
            header = profile.preprocess(header)

            # Execute profile
            @cache.write(profile.exe(header), header["regex"])

            # Display results from cache
            @cache.shortcut(@config) if (shortcut)
        rescue Interrupt
            # ^C
        end
    end
end

require "zoom/cache"
require "zoom/config"
require "zoom/editor"
require "zoom/error"
require "zoom/profile"
Fagin.find_children(
    "Zoom::Profile",
    "#{File.dirname(__FILE__)}/zoom/profile"
)
require "zoom/profile_manager"
require "zoom/security_profile"
Fagin.find_children(
    "Zoom::SecurityProfile",
    "#{File.dirname(__FILE__)}/zoom/profile"
)

# Load custom profiles
Fagin.find_children("Zoom::Profile", "~/.config/zoom")
Fagin.find_children("Zoom::SecurityProfile", "~/.config/zoom")
