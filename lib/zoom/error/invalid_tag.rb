class Zoom::Error::InvalidTag < Zoom::Error
    def initialize(tag = nil)
        super("Invalid tag: #{tag}") if (tag)
        super("Invalid tag") if (tag.nil?)
    end
end
