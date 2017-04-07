class Zoom::Profile::Find < Zoom::Profile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        a = "-print" if (a.nil? || a.empty?)
        f ||= ""
        o ||= "find"
        super(n, o, f, b, a)
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
            when "ignore"
                value.each do |v|
                    to.push("-name \"#{v}\" -prune -o")
                end
            end
        end
        return to.join(" ")
    end
end
