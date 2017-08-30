require "minitest/autorun"
require "pathname"
require "zoom"

class ZoomTest < Minitest::Test
    def setup
        @zoom = Zoom.new("/tmp/zoom_cache", "/tmp/zoomrc")
        @zoom.config.add_security_profiles
        @tools = @zoom.config.get_profile_names.select do |tool|
            case tool
            when "ack", "ag", "grep", "pt", "rg"
                true
            else
                false
            end
        end
    end

    def teardown
        system("rm -f /tmp/zoom_cache /tmp/zoomrc")
    end

    def test_find
        if (!@zoom.config.has_profile?("find"))
            skip "Find profile not found"
        end

        header = Hash.new
        header["paths"] = "test/test_src"
        header["regex"] = "*php*"
        header["profile_name"] = "find"

        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(11, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(11, results.length)

        header["translate"] = Hash.new
        header["translate"]["ignore"] = ["unsafe_php"]

        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(5, results.length)

        header["args"] = "-type"
        header["paths"] = "test/test_src/tools"
        header["regex"] = "f"
        header["translate"] = Hash.new

        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(14, results.length)
    end

    def test_multiple_matches
        @tools.each do |tool|
            header = Hash.new
            header["paths"] = "test/test_src/multiple_matches"
            header["regex"] = "(as)(df)"
            header["profile_name"] = tool

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.3", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.3", "#{tool}.#{results.length}")
        end
    end

    def test_passwords
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/passwords"
            header["profile_name"] = "passwords"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.36", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.36", "#{tool}.#{results.length}")
        end
    end

    def test_search_tools
        @tools.each do |tool|
            header = Hash.new
            header["paths"] = "test/test_src/tools"
            header["regex"] = "eval"
            header["profile_name"] = tool

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.8", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.8", "#{tool}.#{results.length}")

            header["translate"] = Hash.new
            header["translate"]["ignore"] = ["*.php*"]

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.3", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_c
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_c"
            header["profile_name"] = "unsafe_c"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.195", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.195", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_java
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_java"
            header["profile_name"] = "unsafe_java"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.10", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.10", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_js
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_js"
            header["profile_name"] = "unsafe_js"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.12", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.12", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_php
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_php"
            header["profile_name"] = "unsafe_php"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.336", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.336", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_python
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_python"
            header["profile_name"] = "unsafe_python"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.8", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.8", "#{tool}.#{results.length}")
        end
    end

    def test_unsafe_ruby
        @tools.each do |tool|
            Zoom::ProfileManager.force_tool(tool)

            header = Hash.new
            header["paths"] = "test/test_src/unsafe_ruby"
            header["profile_name"] = "unsafe_ruby"

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.66", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.66", "#{tool}.#{results.length}")
        end
    end

    def test_word_regexp
        @tools.each do |tool|
            header = Hash.new
            header["paths"] = "test/test_src/tools"
            header["regex"] = "scanf"
            header["profile_name"] = tool

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.24", "#{tool}.#{results.length}")

            header["translate"] = Hash.new
            header["translate"]["word-regexp"] = ""

            @zoom.run(header, false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.4", "#{tool}.#{results.length}")

            @zoom.repeat(false)
            results = @zoom.cache.get_results
            assert_equal("#{tool}.4", "#{tool}.#{results.length}")
        end
    end

    def test_zoom_exceptions
        assert_raises(Zoom::Error::ExecutableNotFound) do
            @zoom.config.editor("asdf")
        end
    end
end
