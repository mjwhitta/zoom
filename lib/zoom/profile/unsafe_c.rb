require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::UnsafeC < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        flags = ""
        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case --cc --cpp"
        when "ag"
            flags = "-S -G \"\\.(c|h)(pp)?$\""
        when "pt"
            flags = "-S -G \"\\.(c|h)(pp)?$\""
        when "grep"
            flags = "-i --include=\"*.[ch]\" --include=\"*.[ch]pp\""
        end

        super(n, op, flags)
        @pattern = [
            "(",
            [
                "_splitpath",
                "ato[fil]",
                "gets",
                "makepath",
                "(sn?)?scanf",
                "str(cat|cpy|len)",
                "v?sprintf"
            ].join("|"),
            ")",
            "\\("
        ].join
        @taggable = true
    end
end
