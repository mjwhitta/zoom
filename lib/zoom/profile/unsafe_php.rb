class Zoom::SecurityProfile::UnsafePhp < Zoom::SecurityProfile
    def initialize(n = nil, o = nil, f = nil, b = nil, a = nil)
        case Zoom::ProfileManager.default_profile
        when /^ack(-grep)?$/
            f ||= "--smart-case --php"
        when "ag", "pt"
            f ||= "-S -G \"\\.ph(p[345t]?|tml)$\""
        when "grep"
            f ||= [
                "-i",
                "--include=\"*.php\"",
                "--include=\"*.php[345t]\"",
                "--include=\"*.phtml\""
            ].join(" ")
        end

        super(n, nil, f, b, a)
        # From here: https://www.eukhost.com/blog/webhosting/dangerous-php-functions-must-be-disabled/
        # OMG is anything safe?!
        @pattern = [
            "\\`",
            "|",
            "\\$_GET\\[",
            "|",
            "(^|[^\\nA-Za-z_])",
            "(",
            "(include|require)(_once)?",
            "|",
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
                "ini_(alter|get_all|restore)",
                "inject_code",
                "mysql_pconnect",
                "openlog",
                "passthru",
                "pcntl_exec",
                "php_uname",
                "phpAds_(remoteInfo|XmlRpc|xmlrpc(De|En)code)",
                "popen",
                "posix_(getpwuid|kill|mkfifo|set(pg|s|u)id|uname)",
                "preg_replace",
                "proc_(close|get_status|nice|open|terminate)",
                "(shell_)?exec",
                "sys(log|tem)",
                "xmlrpc_entity_decode"
            ].join("|"),
            ")",
            "\\(",
            ")"
        ].join
        @taggable = true
    end
end
