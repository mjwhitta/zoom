require "minitest/autorun"
require "pathname"
require "zoom"

class ZoomTest < Minitest::Test
    def setup
        @zoom = Zoom.new("/tmp/zoom_cache", "/tmp/zoomrc")
        @zoom.config.add_security_profiles
    end

    def teardown
        system("rm -f /tmp/zoom_cache /tmp/zoomrc")
    end

    def test_ack
        if (!@zoom.config.has_profile?("ack"))
            skip "Ack profile not found"
        end

        header = Hash.new
        header["paths"] = [
            "test/test_src/unsafe_c",
            "test/test_src/unsafe_java",
            "test/test_src/unsafe_js",
            "test/test_src/unsafe_php",
            "test/test_src/unsafe_python",
        ].join(" ")
        header["pattern"] = "eval"
        header["profile_name"] = "ack"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        header["translate"] = Hash.new
        header["translate"]["ignore"] = [".*php.*"]
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(3, results.length)
    end

    def test_ag
        if (!@zoom.config.has_profile?("ag"))
            skip "Ag profile not found"
        end

        header = Hash.new
        header["paths"] = [
            "test/test_src/unsafe_c",
            "test/test_src/unsafe_java",
            "test/test_src/unsafe_js",
            "test/test_src/unsafe_php",
            "test/test_src/unsafe_python",
        ].join(" ")
        header["pattern"] = "eval"
        header["profile_name"] = "ag"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        header["translate"] = Hash.new
        header["translate"]["ignore"] = ["*php*"]
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(3, results.length)
    end

    def test_find
        if (!@zoom.config.has_profile?("find"))
            skip "Find profile not found"
        end

        header = Hash.new
        header["paths"] = [
            "test/test_src/unsafe_c",
            "test/test_src/unsafe_java",
            "test/test_src/unsafe_js",
            "test/test_src/unsafe_php",
            "test/test_src/unsafe_python",
        ].join(" ")
        header["pattern"] = "*php*"
        header["profile_name"] = "find"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(6, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(6, results.length)

        header["args"] = "-type f"
        header["pattern"] = ""
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(14, results.length)
    end

    def test_grep
        if (!@zoom.config.has_profile?("grep"))
            skip "Grep profile not found"
        end

        header = Hash.new
        header["paths"] = [
            "test/test_src/unsafe_c",
            "test/test_src/unsafe_java",
            "test/test_src/unsafe_js",
            "test/test_src/unsafe_php",
            "test/test_src/unsafe_python",
        ].join(" ")
        header["pattern"] = "eval"
        header["profile_name"] = "grep"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        header["translate"] = Hash.new
        header["translate"]["ignore"] = ["*php*"]
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(2, results.length)
    end

    def test_passwords
        header = Hash.new
        header["paths"] = "test/test_src/passwords"
        header["profile_name"] = "passwords"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(16, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(16, results.length)
    end

    def test_pt
        if (!@zoom.config.has_profile?("pt"))
            skip "Pt profile not found"
        end

        header = Hash.new
        header["paths"] = [
            "test/test_src/unsafe_c",
            "test/test_src/unsafe_java",
            "test/test_src/unsafe_js",
            "test/test_src/unsafe_php",
            "test/test_src/unsafe_python",
        ].join(" ")
        header["pattern"] = "eval"
        header["profile_name"] = "pt"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        header["translate"] = Hash.new
        header["translate"]["ignore"] = ["*php*"]
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(3, results.length)
    end

    def test_unsafe_c
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_c"
        header["profile_name"] = "unsafe_c"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(56, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(56, results.length)
    end

    def test_unsafe_java
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_java"
        header["profile_name"] = "unsafe_java"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(10, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(10, results.length)
    end

    def test_unsafe_js
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_js"
        header["profile_name"] = "unsafe_js"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(4, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(4, results.length)
    end

    def test_unsafe_php
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_php"
        header["profile_name"] = "unsafe_php"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(336, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(336, results.length)
    end

    def test_unsafe_python
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_python"
        header["profile_name"] = "unsafe_python"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(8, results.length)
    end

    def test_unsafe_ruby
        header = Hash.new
        header["paths"] = "test/test_src/unsafe_ruby"
        header["profile_name"] = "unsafe_ruby"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(48, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(48, results.length)
    end

    def test_word_regexp
        if (!@zoom.config.has_profile?("grep"))
            skip "Grep profile not found"
        end

        header = Hash.new
        header["paths"] = "test/test_src/unsafe_c"
        header["pattern"] = "str"
        header["profile_name"] = "grep"
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(12, results.length)

        header["translate"] = Hash.new
        header["translate"]["word-regexp"] = ""
        @zoom.run(header, false)
        results = @zoom.cache.get_results
        assert_equal(0, results.length)

        @zoom.repeat(false)
        results = @zoom.cache.get_results
        assert_equal(0, results.length)
    end

    def test_zoom_exceptions
        assert_raises(Zoom::Error::ExecutableNotFound) do
            @zoom.config.editor("asdf")
        end
    end
end
