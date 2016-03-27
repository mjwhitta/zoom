class Zoom::Cache::Result
    attr_reader :contents
    attr_reader :filename
    attr_reader :lineno
    attr_reader :match
    attr_reader :tag

    def args
        return @cache.zoom_args
    end

    def grep_like?
        return @grep_like
    end

    def initialize(tag, contents, cache)
        @cache = cache
        @contents = contents
        @filename = nil
        @grep_like = false
        @lineno = nil
        @match = nil
        @tag = tag

        @contents.unpack("C*").pack("U*").gsub(
            /([\u0080-\u00ff]+)/,
            "\\1".dump[1..-2]
        ).match(/^([^:]+):(\d+)[:-](.*)/) do |m|
            next if (m.nil?)

            @grep_like = true
            @filename = m[1]
            @lineno = m[2]
            @match = m[3]
        end
    end

    def pattern
        return @cache.zoom_pattern
    end

    def profile_name
        return @cache.zoom_profile_name
    end

    def pwd
        return @cache.zoom_pwd
    end
end
