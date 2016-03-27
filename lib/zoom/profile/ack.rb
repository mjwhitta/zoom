class Zoom::Profile::Ack < Zoom::Profile
    def initialize(n, o = "ack", f = "--smart-case", b = "", a = "")
        # Special case because of debian
        if ((o == "ack") && ScoobyDoo.where_are_you("ack-grep"))
            o = "ack-grep"
        end

        super(n, o, f, b, a)
        @taggable = true
    end
end
