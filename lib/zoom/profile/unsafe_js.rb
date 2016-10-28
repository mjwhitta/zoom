require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::UnsafeJs < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        # I don't care about test code
        after = "| \\grep -v \"^[^:]*test[^:]*:[0-9]+:\""
        flags = ""

        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case --js"
        when "ag"
            flags = "-S -G \"\\.js$\""
        when "pt"
            flags = "-S -G \"\\.js$\""
        when "grep"
            flags = "-i --include=\"*.js\""
        end

        super(n, op, flags, "", after)
        @pattern = "\\.((eval|html)\\(|innerHTML)"
        @taggable = true
    end
end
