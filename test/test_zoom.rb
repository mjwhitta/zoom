require "minitest/autorun"
require "pathname"
require "zoom"

class RPassTest < Minitest::Test
    def setup
        @zoom = Zoom.new(
            "/tmp/zoom_cache",
            "/tmp/zoomrc"
        )
    end

    def teardown
        system("rm -f /tmp/zoom_cache /tmp/zoomrc")
    end

    def test_zoom_exceptions
        assert_raises(Zoom::Error::ExecutableNotFound) do
            @zoom.config.editor("asdf")
        end
    end
end
