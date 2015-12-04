class Zoom::Error < RuntimeError
end

require "zoom/error/executable_not_found_error"
require "zoom/error/invalid_tag_error"
require "zoom/error/profile_already_exists_error"
require "zoom/error/profile_can_not_be_modified_error"
require "zoom/error/profile_class_unknown_error"
require "zoom/error/profile_does_not_exist_error"
