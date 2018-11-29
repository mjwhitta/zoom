require "io/wait"
require "json"
require "pathname"

class Zoom::Cache
    def args
        return nil if (@header.nil?)
        return @header["args"]
    end

    def available_tags
        return (1..get_results.length).to_a
    end

    def clear
        @cache_file.delete if (@cache_file.exist?)
        @results = nil
        @thread.kill if (@thread)
        @thread = nil
        @header = nil
    end

    def empty?
        read if (@thread.nil?)
        return true if (@thread.nil?)
        while (@thread.alive? && (@header.nil? || @header.empty?))
            sleep 0.1
        end
        return @header.empty?
    end

    def get_results(tags = nil)
        if (tags.nil?)
            begin
                @thread.join if (@thread)
            rescue Interrupt
                puts
            end
            return Array.new if (empty?)
            return @results
        end

        results = Array.new
        parse_tags(tags).each do |tag|
            raise Zoom::Error::InvalidTag.new(tag) if (@thread.nil?)

            while ((tag > @results.length) && @thread.alive?)
                sleep 0.1
            end

            if (tag > @results.length)
                raise Zoom::Error::InvalidTag.new(tag)
            end

            results.push(@results.at(tag - 1))
        end

        return results
    end

    def header(header = nil)
        return nil if (header.nil? && empty?)
        return @header if (header.nil?)

        # This causes the cache to be "empty" so don't do it! Leaving
        # this here so I don't forget.
        # @header = header

        File.open(@cache_file, "a") do |f|
            f.write("ZOOM_HEADER=#{JSON.generate(header)}\n")
        end
    end

    def initialize(config, file = nil)
        file = "~/.cache/zoom/cache" if (file.nil?)

        @cache_file = Pathname.new(file).expand_path
        @config = config
        @results = nil
        @thread = nil
        @header = Hash.new

        FileUtils.mkdir_p(@cache_file.dirname)
        read
    end

    def parse_tags(input)
        if (input.nil? || input.empty?)
            raise Zoom::Error::InvalidTag.new
        end

        tags = Array.new
        input.split(",").each do |num|
            if (!num.scan(/^\d+$/).empty?)
                tags.push(num.to_i)
            elsif (!num.scan(/^\d+-\d+$/).empty?)
                range = num.split("-")
                (range[0].to_i..range[1].to_i).each do |i|
                    tags.push(i)
                end
            else
                raise Zoom::Error::InvalidTag.new(num)
            end
        end
        raise Zoom::Error::InvalidTag.new(0) if (tags.include?(0))
        return tags
    end
    private :parse_tags

    def paths
        return nil if (@header.nil?)
        return @header["paths"]
    end

    def profile_name
        return nil if (@header.nil?)
        return @header["profile_name"]
    end

    def pwd
        return nil if (@header.nil?)
        return @header["pwd"]
    end

    def read
        return if (!@cache_file.exist?)

        @results = Array.new
        tag = 1
        @thread.kill if (@thread)
        @thread = Thread.new do
            profile = nil

            # Read in cache
            File.open(@cache_file) do |cache|
                cache.each do |line|
                    line.chomp!
                    if (line.start_with?("ZOOM_HEADER="))
                        @header = JSON.parse(
                            line.gsub("ZOOM_HEADER=", "")
                        )

                        if (!@config.has_profile?(profile_name))
                            raise
                            Zoom::Error::ProfileDoesNotExist.new(
                                profile_name
                            )
                        end
                        profile = @config.get_profile(profile_name)
                    elsif (line.match(/^-?-?$/))
                        # Ignore dividers when searching with context
                        # and empty lines
                    else
                        @results.push(
                            Zoom::Cache::Result.new(
                                tag,
                                line,
                                self,
                                profile.grep_like_tags?
                            )
                        )
                        tag += 1
                    end
                end
            end
        end
    end

    def regex
        return nil if (@header.nil?)
        return @header["regex"]
    end

    def shortcut
        return if (empty?)

        @config.validate_colors
        if (!@config.has_profile?(profile_name))
            raise Zoom::Error::ProfileDoesNotExist.new(profile_name)
        end

        profile = @config.get_profile(profile_name)
        if (!profile.taggable)
            get_results.each do |result|
                puts result.contents
            end
            return
        end

        curr_filename = nil
        get_results.each do |result|
            if (result.grep_like?)
                if (result.filename != curr_filename)
                    puts if (curr_filename)
                    puts @config.hilight_filename(result.filename)
                    curr_filename = result.filename
                end

                puts [
                    @config.hilight_tag("[#{result.tag}]"),
                    "#{@config.hilight_lineno(result.lineno)}:",
                    result.match.gsub(
                        /(#{regex})/i,
                        @config.hilight_match("\\1")
                    )
                ].join(" ")
            else
                if (result.filename)
                    if (result.filename != curr_filename)
                        puts if (curr_filename)
                        puts @config.hilight_filename(result.filename)
                        curr_filename = result.filename
                    end
                end

                tag = result.tag
                line = result.contents
                puts [@config.hilight_tag("[#{tag}]"), line].join(" ")
            end
        end
    end

    def write(str, r = nil)
        return if (str.nil?)

        if (!str.valid_encoding?)
            str = str.encode(
                "UTF-16be",
                :invalid => :replace,
                :replace => "?"
            ).encode("UTF-8")
        end

        File.open(@cache_file, "a") do |f|
            str.gsub(/\r/, "^M").split("\n").each do |line|
                if (r && line.match(/^[^:]+:[0-9]+:.+$/))
                    line.match(/^([^:]+:[0-9]+:)(.+)$/) do |m|
                        m[2].scan(
                            /(.{0,128}#{r}.{0,128})/i
                        ) do |n|
                            f.write("#{m[1]}#{n[0]}\n")
                        end
                    end
                else
                    line.gsub!(/^(.{128}).*(.{128})$/, "\\1...\\2")
                    f.write("#{line}\n")
                end
            end
        end
    end
end

require "zoom/cache/result"
