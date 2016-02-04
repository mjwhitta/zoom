require "minitest/autorun"
require "pathname"
require "zoom"

class RPassTest < Minitest::Test
    def setup
        files = [
            "~/.zoom_cache",
            "~/.zoom_profiles.rb",
            "~/.zoom_shortcuts",
            "~/.zoominfo",
            "~/.zoomrc"
        ]

        files.each do |filename|
            file = Pathname.new(filename).expand_path
            system("mv -f #{file} #{file}.minitest") if (file.exist?)
        end

        @zoom = Zoom.new
    end

    def teardown
        files = [
            "~/.zoom_cache",
            "~/.zoom_profiles.rb",
            "~/.zoom_shortcuts",
            "~/.zoominfo",
            "~/.zoomrc"
        ]

        files.each do |filename|
            file = Pathname.new("#{filename}.minitest").expand_path
            system("mv -f #{file} #{filename}") if (file.exist?)
        end
    end

    def test_zoom_exceptions
        assert_raises(Zoom::Error::ExecutableNotFoundError) do
            @zoom.configure_editor("asdf")
        end

        assert_raises(Zoom::Error::ProfileAlreadyExistsError) do
            @zoom.add_profile("grep", "GrepProfile")
        end

        assert_raises(Zoom::Error::ProfileCanNotBeModifiedError) do
            @zoom.delete_profile("default")
        end

        assert_raises(Zoom::Error::ProfileCanNotBeModifiedError) do
            @zoom.delete_profile("zoom_find")
        end

        assert_raises(Zoom::Error::ProfileCanNotBeModifiedError) do
            @zoom.rename_profile("asdf", "default")
        end

        assert_raises(Zoom::Error::ProfileCanNotBeModifiedError) do
            @zoom.rename_profile("asdf", "zoom_find")
        end

        assert_raises(Zoom::Error::ProfileClassUnknownError) do
            @zoom.add_profile("asdf", "AsdfProfile")
        end

        assert_raises(Zoom::Error::ProfileDoesNotExistError) do
            @zoom.delete_profile("asdf")
        end
    end
end
