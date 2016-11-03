require "fagin"
require "pathname"

class Zoom
    attr_reader :cache
    attr_reader :config

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

        # All results should be from the same profile
        profile = @config.get_profile(results[0].profile_name)
        profile.go(@config.editor, results)
    end

    def repeat(shortcut = true)
        return if (@cache.empty?)
        run(@cache.header, shortcut)
    end

    def run(header, shortcut = true)
        # Ensure header has no nil
        ["args", "paths", "pattern", "profile_name"].each do |key|
            header[key] ||= ""
        end
        header["pwd"] = Dir.pwd
        header["translate"] ||= Array.new

        profile_name = header["profile_name"]
        if (profile_name.empty?)
            profile_name = @config.current_profile_name
            header["profile_name"] = profile_name
        end

        if (!@config.has_profile?(profile_name))
            raise Zoom::Error::ProfileDoesNotExist.new(profile_name)
        end

        profile = @config.get_profile(profile_name)
        if (!profile.pattern.empty?)
            header["pattern"] = profile.pattern
        end

        begin
            # Clear cache
            @cache.clear

            # Store needed details
            @cache.header(header)

            # This will translate and/or append args such that the
            # output will be something Zoom can process
            header = profile.preprocess(header)

            # Execute profile
            @cache.write(profile.exe(header))

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
