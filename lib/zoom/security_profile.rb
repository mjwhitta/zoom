class Zoom::SecurityProfile < Zoom::Profile
    def after(a = nil)
        super
        return @tool.after(a)
    end

    def before(b = nil)
        super
        return @tool.before(b)
    end

    def exe(header)
        sync
        return @tool.exe(header)
    end

    def flags(f = nil)
        super
        return @tool.flags(f)
    end

    def grep_like_format_flags(all = false)
        super
        @tool.grep_like_format_flags(all)
        @format_flags = @tool.format_flags
        @taggable = @tool.taggable
    end

    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        clas = Zoom::ProfileManager.class_by_tool(t)
        clas ||= Zoom::ProfileManager.default_class
        @tool = Zoom::Profile.profile_by_name(clas).new(n)
        super(n, @tool.tool, f, b, a)
    end

    def only_exts_and_files
        @tool.exts = @exts
        @tool.files = @files
        return @tool.only_exts_and_files
    end

    def preprocess(header)
        sync
        return @tool.preprocess(header)
    end

    def sync
        @tool.exts = @exts
        @tool.files = @files
        @tool.regex = @regex
    end
    private :sync

    def tool(t = nil)
        super
        return @tool.tool(t)
    end

    def translate(from)
        return @tool.translate(from)
    end
end
