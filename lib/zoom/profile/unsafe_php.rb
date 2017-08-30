class Zoom::SecurityProfile::UnsafePhp < Zoom::SecurityProfile
    def initialize(n = nil, t = nil, f = nil, b = nil, a = nil)
        t = Zoom::ProfileManager.default_tool

        super(n, t, f, b, a)
        @exts = ["php", "php3", "php4", "php5", "phpt", "phtml"]

        # From here: https://www.eukhost.com/blog/webhosting/dangerous-php-functions-must-be-disabled/
        # OMG is anything safe?!
        functions = [
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
        ]
        get_params = "\\$_GET\\["
        includes = "(include|require)(_once)?"
        shell = "`"
        start_or_not_variable = "(^|[^\\nA-Za-z_])"

        @regex = [
            shell,
            get_params,
            [
                start_or_not_variable,
                "(",
                [
                    includes,
                    "(#{functions.join("|")})\\(",
                ].join("|"),
                ")"
            ].join
        ].join("|")
    end
end
