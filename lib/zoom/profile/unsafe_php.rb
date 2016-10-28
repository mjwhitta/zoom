require "zoom/profile_manager"

clas = Zoom::ProfileManager.default_profile.capitalize
superclass = Zoom::Profile.profile_by_name("Zoom::Profile::#{clas}")
class Zoom::Profile::UnsafePhp < superclass
    def initialize(n, o = nil, f = "", b = "", a = "")
        # I don't care about test code
        after = "| \\grep -v \"^[^:]*test[^:]*:[0-9]+:\""
        flags = ""

        op = Zoom::ProfileManager.default_profile
        case op
        when /^ack(-grep)?$/
            flags = "--smart-case --php"
        when "ag"
            flags = "-S -G \"\\.ph(p[345t]?|tml)$\""
        when "pt"
            flags = "-S -G \"\\.ph(p[345t]?|tml)$\""
        when "grep"
            flags = [
                "-i",
                "--include=\"*.php\"",
                "--include=\"*.php[345t]\"",
                "--include=\"*.phtml\""
            ].join(" ")
        end

        super(n, op, flags, "", after)
        # From here: https://www.eukhost.com/blog/webhosting/dangerous-php-functions-must-be-disabled/
        # OMG is anything safe?!
        @pattern = [
            "\\`|",
            "\\$_GET\\[|",
            "(",
            [
                "apache_(child_terminate|setenv)",
                "assert",
                "create_function",
                "define_syslog_variables",
                "escapeshell(arg|cmd)",
                "eval",
                "fp(ut)?",
                "ftp_(connect|exec|get|login|(nb_f)?put|raw(list)?)",
                "highlight_file",
                "include(_once)?",
                "ini_(alter|get_all|restore)",
                "inject_code",
                "mysql_pconnect",
                "openlog",
                "passthru",
                "pcntl_exec",
                "php_uname",
                "phpAds_(remoteInfo|XmlRpc|xmlrpc(De|En)code)",
                "popen",
                "posix_(getpwuid|kill|mkfifo|set(pg|s|u)id|_uname)",
                "preg_replace",
                "proc_(close|get_status|nice|open|terminate)",
                "require(_once)?",
                "(shell_)?exec",
                "sys(log|tem)",
                "xmlrpc_entity_decode"
            ].join("|"),
            ")\\("
        ].join
        @taggable = true
    end
end
