class Zoom::Error < RuntimeError
end

require "zoom/error/executable_not_found"
require "zoom/error/invalid_color"
require "zoom/error/invalid_tag"
require "zoom/error/profile_class_unknown"
require "zoom/error/profile_does_not_exist"
require "zoom/error/profile_not_named"
require "zoom/error/regex_not_provided"
