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

    def initialize(cache = nil, rc = nil, hilight = false)
        @@hilight = hilight
        @cache = Zoom::Cache.new(cache)
        @config = Zoom::Config.new(rc)

        # Prioritize false, so only reassign if true
        @@hilight = @config.hilight if (hilight)
    end

    def open(results)
        return if (results.nil? || results.empty?)

        # All results should be from the same profile
        profile = @config.get_profile(results[0].profile_name)
        profile.go(@config.editor, results)
    end

    def repeat
        return if (@cache.empty?)

        run(
            @cache.profile_name,
            @cache.args,
            @cache.pattern
        )
    end

    def run(prof_name, args, pattern)
        prof_name = @config.current_profile_name if (prof_name.nil?)

        if (!@config.has_profile?(prof_name))
            raise Zoom::Error::ProfileDoesNotExist.new(prof_name)
        end

        profile = @config.get_profile(prof_name)
        begin
            @cache.clear

            # Store needed details
            if (pattern && profile.pattern.empty?)
                @cache.args(args)
                @cache.pattern(pattern)
            else
                @cache.args("")
                @cache.pattern(profile.pattern)
            end
            @cache.profile_name(prof_name)
            @cache.pwd(Dir.pwd)

            # Execute profile
            @cache.write(profile.exe(args, pattern))

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
