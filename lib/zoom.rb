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

    def repeat
        return if (@cache.empty?)
        run(@cache.header)
    end

    def run(header)
        profile_name = header["profile_name"]
        args = header["args"]
        pattern = header["pattern"]
        paths = header["paths"]

        if (profile_name.nil?)
            profile_name = @config.current_profile_name
            header["profile_name"] = profile_name
        end

        if (!@config.has_profile?(profile_name))
            raise Zoom::Error::ProfileDoesNotExist.new(profile_name)
        end

        profile = @config.get_profile(profile_name)
        if (pattern.nil? || !profile.pattern.empty?)
            header["pattern"] = profile.pattern
        end
        header["pwd"] = Dir.pwd

        begin
            # Clear cache
            @cache.clear

            # Store needed details
            @cache.header(header)

            # Execute profile
            @cache.write(profile.exe(args, pattern, paths))

            # Display results from cache
            @cache.shortcut(@config)
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
require "zoom/profile_manager"
