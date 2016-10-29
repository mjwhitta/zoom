class Zoom::Cache::Result
    attr_reader :contents
    attr_reader :filename
    attr_reader :lineno
    attr_reader :match
    attr_reader :tag

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

    def profile_name
        return @cache.profile_name
    end

    def pwd
        return @cache.pwd
    end
end
