#!/usr/bin/env ruby

require "io/wait"
require "json"
require "optparse"
require "pathname"
require "shellwords"

class ZoomExit
    GOOD = 0
    INVALID_OPTION = 1
    UNKNOWN_PROFILE_CLASS = 2
    PROFILE_DOES_NOT_EXIST = 3
    PROFILE_ALREADY_EXISTS = 4
    CAN_NOT_MODIFY_PROFILE = 5
    MISSING_ARGUMENT = 6
end

class Profile < Hash
    def append(append = nil)
        self["append"] = append if (append)
        return self["append"]
    end

    def colors
        # TODO color support
        ""
    end

    def exe(args, pattern)
        system("#{self.to_s} #{args} #{pattern} #{self.append}")
    end

    def flags(flags = nil)
        self["flags"] = flags if (flags)
        return self["flags"]
    end

    def self.from_json(json)
        begin
            return Object::const_get(json["class"]).new(
                json["operator"],
                json["flags"],
                json["prepend"],
                json["append"]
            )
        rescue NameError => e
            puts "Unknown Profile class #{json["class"]}!"
            exit ZoomExit::UNKNOWN_PROFILE_CLASS
        end
    end

    def info()
        [
            "Class   : " + self.class.to_s,
            "Prepend : " + self["prepend"],
            "Operator: " + self["operator"],
            "Flags   : " + self["flags"],
            "Append  : " + self["append"]
        ].join("\n").strip
    end

    def initialize(
        operator = "echo",
        flags = "",
        envprepend = "",
        append = ""
    )
        self["class"] = self.class.to_s
        self.operator(operator)
        self.flags(flags)
        self.prepend(envprepend)
        self.append(append)
    end

    def operator(operator = nil)
        if (operator)
            op = find_in_path(operator)
            if (op)
                self["operator"] = op
            else
                self["operator"] = find_in_path("grep")
            end
        end
        return self["operator"]
    end

    def prepend(envprepend = nil)
        self["prepend"] = envprepend if (envprepend)
        return self["prepend"]
    end

    def to_s()
        [
            self.colors,
            self["prepend"],
            self["operator"],
            self["flags"]
        ].join(" ").strip
    end
end

class AgProfile < Profile
    def colors
        '--color-match "47;1;30" --color-line-number "0;37"'
    end

    def exe(args, pattern)
        if (!pattern.nil? && !pattern.empty?)
            system(
                "#{self.to_s} --pager \"#{PAGER}\" #{args} " \
                "#{pattern.shellescape} #{self.append}"
            )
        else
            system(
                "#{self.to_s} --pager \"#{PAGER}\" #{args} " \
                "#{self.append}"
            )
        end
    end

    def initialize(
        operator = "ag",
        flags = "-S --ignore=\"*.pdf\"",
        envprepend = "",
        append = ""
    )
        super(operator, flags, envprepend, append)
    end

    def to_s()
        [
            self["prepend"],
            self["operator"],
            self.colors,
            self["flags"]
        ].join(" ").strip
    end
end

class AckProfile < Profile
    def colors
        'ACK_COLOR_LINENO=white ACK_COLOR_MATCH="black on_white"'
    end

    def exe(args, pattern)
        if (!pattern.nil? && !pattern.empty?)
            system(
                "#{self.to_s} --pager \"#{PAGER}\" #{args} " \
                "#{pattern.shellescape} #{self.append}"
            )
        else
            system(
                "#{self.to_s} --pager \"#{PAGER}\" #{args} " \
                "#{self.append}"
            )
        end
    end

    def initialize(
        operator = nil,
        flags = "--smart-case",
        envprepend = "",
        append = ""
    )
        # Special case because of debian
        if (find_in_path("ack"))
            operator ||= "ack"
        elsif (find_in_path("ack-grep"))
            operator ||= "ack-grep"
        else
            # Oops
            operator ||= "echo"
            if (operator == "echo")
                flags = "#"
                envprepend = ""
                append = ""
            end
        end

        super(operator, flags, envprepend, append)
    end
end

class GrepProfile < Profile
    def colors
        [
            'GREP_COLORS="',
            "fn=1;32:",
            "ln=0;37:",
            "ms=47;1;30:",
            "mc=47;1;30:",
            "sl=:cx=:bn=:se=",
            '"'
        ].join.strip
    end

    def exe(args, pattern)
        # Emulate ag/ack as much as possible
        if (!pattern.nil? && !pattern.empty?)
            system(
                "#{self.to_s} #{args} #{pattern.shellescape} " \
                "#{self.append} | sed \"s|\\[K[:-]|\\[K\\n|\" | " \
                "#{PAGER}"
            )
        else
            system(
                "#{self.to_s} #{args} #{self.append} | " \
                "sed \"s|\\[K[:-]|\\[K\\n|\" | #{PAGER}"
            )
        end
    end

    def initialize(
        operator = "grep",
        flags = [
            "--color=always",
            "-EHIinR",
            "--exclude-dir=.bzr",
            "--exclude-dir=.git",
            "--exclude-dir=.svn"
        ].join(" ").strip,
        envprepend = "",
        append = "."
    )
        super(operator, flags, envprepend, append)
    end
end

class FindProfile < Profile
    def exe(args, pattern)
        if (!pattern.nil? && !pattern.empty?)
            system(
                "#{self.to_s} #{args} \"#{pattern}\" " \
                "#{self.append} | #{PAGER}"
            )
        else
            system(
                "#{self.to_s} #{args} \"*\" #{self.append} | #{PAGER}"
            )
        end
    end

    def initialize(
        operator = "find",
        flags = ". -name",
        envprepend = "",
        append = ""
    )
        super(operator, flags, envprepend, append)
    end
end

def add_profile()
    default_op = "grep"
    if (find_in_path("ag"))
        default_op = "ag"
    elsif (find_in_path("ack"))
        default_op = "ack"
    elsif (find_in_path("ack-grep"))
        default_op = "ack-grep"
    end

    case default_op
    when "ag"
        puts "Enter class (default AgProfile):"
    when "ack", "ack-grep"
        puts "Enter class (default AckProfile):"
    when "grep"
        puts "Enter class (default GrepProfile):"
    end

    clas = gets.chomp
    puts if (!clas.nil? && !clas.empty?)

    case default_op
    when "ag"
        clas = "AgProfile" if (clas.nil? || clas.empty?)
    when "ack", "ack-grep"
        clas = "AckProfile" if (clas.nil? || clas.empty?)
    when "grep"
        clas = "GrepProfile" if (clas.nil? || clas.empty?)
    end

    default_class = nil
    begin
        default_class = Object::const_get(clas).new
    rescue NameError => e
        puts "Unknown Profile class #{clas}!"
        exit ZoomExit::UNKNOWN_PROFILE_CLASS
    end

    edit_profile(default_class)

    return default_class
end

def default_zoominfo()
    info = Hash.new
    info["profile"] = "default"

    # Reset last command to be empty
    info["last_command"] = Hash.new

    write_zoominfo(info)
end

def default_zoomrc()
    rc = Hash.new
    profs = Hash.new

    # Default ag profiles
    if (find_in_path("ag"))
        ag = AgProfile.new

        all = AgProfile.new
        all.flags("-uS")

        passwords = AgProfile.new
        passwords.flags("-uS")
        passwords.append("\"pass(word|wd)?[^:=,>]? *[:=,>]\"")
    else
        ag = nil
        all = nil
        passwords = nil
    end

    # Default ack profile
    if (find_in_path("ack") || find_in_path("ack-grep"))
        ack = AckProfile.new

        if (!passwords)
            passwords = AckProfile.new
            passwords.append("\"pass(word|wd)?[^:=,>]? *[:=,>]\"")
        end
    else
        ack = nil
    end

    # Default grep profile (emulate ag/ack as much as possible)
    grep = GrepProfile.new
    if (!all)
        all = GrepProfile.new
        all.flags("--color=always -EHinR")
    end
    if (!passwords)
        passwords = GrepProfile.new
        passwords.flags("--color=always -EHinR")
        passwords.append("\"pass(word|wd)?[^:=,>]? *[:=,>]\" .")
    end

    # Create default profile
    if (ag)
        default = ag
    elsif (ack)
        default = ack
    else
        default = grep
    end

    # Create find profile
    find = FindProfile.new

    # Put profiles into rc
    profs["ack"] = ack if (ack)
    profs["ag"] = ag if (ag)
    profs["all"] = all if (all)
    profs["default"] = default
    profs["grep"] = grep
    profs["passwords"] = passwords
    profs["zoom_find"] = find

    # Default editor (use $EDITOR)
    rc["editor"] = ""
    rc["profiles"] = profs

    write_zoomrc(rc)
end

def edit_profile(profile)
    # Get new operator
    puts "Enter operator (default #{profile.operator}):"

    op = find_in_path(gets.chomp)
    puts if (!op.nil? && !op.empty?)

    op = profile.operator if (op.nil? || op.empty?)
    profile.operator(op) if (op != profile.operator)

    # Get new flags
    puts "For empty string put \"empty\""
    puts "Enter flags (default \"#{profile.flags}\"):"

    flags = gets.chomp
    puts if (!flags.nil? && !flags.empty?)

    flags = get_new_value(flags, profile.flags)
    profile.flags(flags) if (flags != profile.flags)

    # Get new prepend
    puts "For empty string put \"empty\""
    puts "Enter prepend (default \"#{profile.prepend}\"):"

    envprepend = gets.chomp
    puts if (!envprepend.nil? && !envprepend.empty?)

    envprepend = get_new_value(envprepend, profile.prepend)
    profile.prepend(envprepend) if (envprepend != profile.prepend)

    # Get new append
    puts "For empty string put \"empty\""
    puts "Enter append (default \"#{profile.append}\"):"

    append = gets.chomp
    puts if (!append.nil? && !append.empty?)

    append = get_new_value(append, profile.append)
    profile.append(append) if (append != profile.append)
end

def exe_command(profile, args, pattern)
    operator = profile.operator.split("/").last

    case operator
    when "ag", "ack", "ack-grep", "grep", "find"
        CACHE_FILE.delete if (CACHE_FILE.exist?)
        profile.exe(args, pattern)
        shortcut_cache(profile)
    else
        profile.exe(args, pattern)
    end
end

def find_in_path(cmd)
    return nil if (!cmd || cmd.empty?)
    return cmd if (is_exe?(cmd))

    path = ENV["PATH"].split(":").uniq.delete_if do |i|
        i.empty?
    end
    path.each do |dir|
        return "#{dir}/#{cmd}" if (is_exe?("#{dir}/#{cmd}"))
    end
    return nil
end

def get_location_of_result(result)
    count = 0
    File.open(SHORTCUT_FILE) do |file|
        file.each do |line|
            count += 1
            if (count == result)
                return line
            end
        end
    end
    return nil
end

def get_new_value(val, default)
    return default if (val.nil? || val.empty?)
    return "" if (val.downcase == "empty")
    return "" if (val.downcase == "\"empty\"")
    return val
end

def is_exe?(cmd)
    exe = Pathname(cmd).expand_path
    return (exe.file? && exe.executable?)
end

def open_editor_to_result(editor, result)
    loc = get_location_of_result(result.to_i)
    if (loc)
        system("#{editor} #{loc}")
    else
        puts "Invalid tag \"#{result}\"!"
    end
end

def parse(args, profile)
    options = Hash.new
    options["pager"] = false
    options["repeat"] = false
    parser = OptionParser.new do |opts|
        opts.banner =
            "Usage: #{File.basename($0)} [OPTIONS] <pattern>"

        opts.on(
            "-a",
            "--add=NAME",
            "Add a new profile with specified name"
        ) do |profile|
            options["add"] = profile
        end

        opts.on("-c", "--cache", "Show previous results") do
            if (CACHE_FILE.exist? && !CACHE_FILE.directory?)
                shortcut_cache(profile)
            end
            exit ZoomExit::GOOD
        end

        opts.on(
            "-d",
            "--delete=NAME",
            "Delete profile with specified name"
        ) do |profile|
            options["delete"] = profile
        end

        opts.on(
            "-e",
            "--edit=NAME",
            "Edit profile with specified name"
        ) do |profile|
            options["edit"] = profile
        end

        opts.on(
            "--editor=EDITOR",
            "Use the specified editor"
        ) do |editor|
            options["editor"] = editor
        end

        opts.on("--examples", "Show some examples") do
            puts [
                "EXAMPLES:",
                "",
                "Add a profile named test:",
                "    $ z --add test",
                "",
                "Edit a profile named test:",
                "    $ z --edit test",
                "",
                "Execute the current profile:",
                "    $ z PATTERN",
                "",
                "Repeat the previous Zoom command:",
                "    $ z --repeat",
                "",
                "Pass additional flags to the choosen operator:",
                "    $ z -- -A 3 PATTERN",
                "",
                "Open a tag:",
                "    $ z --go 10",
                "",
                "Open multiple tags:",
                "    $ z --go 10,20,30-40"
            ].join("\n")
            exit ZoomExit::GOOD
        end

        opts.on("--find", "Use the zoom_find profile") do
            options["use"] = "zoom_find"
        end

        opts.on(
            "-g",
            "--go=NUM",
            "Open editor to search result NUM"
        ) do |g|
            options["go"] = g
        end

        opts.on("-h", "--help", "Display this help message") do
            puts opts
            exit ZoomExit::GOOD
        end

        opts.on("-l", "--list", "List profiles") do
            options["list"] = true
        end

        opts.on(
            "--list-profile-names",
            "List profile names for completion functions"
        ) do
            options["list-profile-names"] = true
        end

        opts.on(
            "--list-tags",
            "List tags for completion functions"
        ) do
            options["list-tags"] = true
        end

        opts.on(
            "--pager",
            "Treat Zoom as a pager (internal use only)"
        ) do
            options["pager"] = true
        end

        opts.on("-r", "--repeat", "Repeat the last Zoom command") do
            options["repeat"] = true
        end

        opts.on("--rc", "Create default .zoomrc file") do
            default_zoominfo
            default_zoomrc
            exit ZoomExit::GOOD
        end

        opts.on(
            "--rename=NAME",
            "Rename the current profile"
        ) do |name|
            options["rename"] = name
        end

        opts.on(
            "-s",
            "--switch=NAME",
            "Switch to profile with specified name"
        ) do |profile|
            options["switch"] = profile
        end

        opts.on(
            "-u",
            "--use=NAME",
            "Use specified profile one time only"
        ) do |profile|
            options["use"] = profile
        end

        opts.on("-w", "--which", "Display the current profile") do
            options["which"] = true
        end

        opts.on(
            "",
            "Do you like to search through code using ag, ack, or " \
            "grep? Good! This",
            "tool is for you! Zoom adds some convenience to " \
            "ag/ack/grep by allowing",
            "you to quickly open your search results in your " \
            "editor of choice. When",
            "looking at large code-bases, it can be a pain to have " \
            "to scroll to",
            "find the filename of each result. Zoom prints a tag " \
            "number in front of",
            "each result that ag/ack/grep outputs. Then you can " \
            "quickly open that",
            "tag number with Zoom to jump straight to the source. " \
            "Zoom is even",
            "persistent across all your sessions! You can search " \
            "in one terminal",
            "and jump to a tag in another terminal from any " \
            "directory!"
        )
    end

    begin
        parser.parse!
    rescue OptionParser::InvalidOption => e
        puts e.message
        puts parser
        exit ZoomExit::INVALID_OPTION
    rescue OptionParser::MissingArgument => e
        puts e.message
        puts parser
        exit ZoomExit::MISSING_ARGUMENT
    end

    case File.basename($0)
    when "zc"
        if (CACHE_FILE.exist? && !CACHE_FILE.directory?)
            shortcut_cache(profile)
        end
        exit ZoomExit::GOOD
    when "zf"
        options["use"] = "zoom_find"
    when "zg"
        options["go"] = args[0]
    when "zl"
        options["list"] = true
    when "zr"
        options["repeat"] = true
    when "z"
        # do nothing, this is the normal usage
    else
        options["use"] = File.basename($0)
    end

    options["pattern"] = args.delete_at(-1)
    options["subargs"] = args.join(" ")
    return options
end

def parse_tags(go)
    tags = Array.new
    go.split(",").each do |num|
        if (!num.scan(/^[0-9]+$/).empty?)
            tags.push(num.to_i)
        elsif (!num.scan(/^[0-9]+-[0-9]+$/).empty?)
            range = num.split("-")
            (range[0].to_i..range[1].to_i).each do |i|
                tags.push(i)
            end
        else
            puts "#{num} was not formatted properly. Ignoring."
        end
    end
    return tags
end

def read_zoominfo()
    default_zoominfo if (!INFO_FILE.exist? && !INFO_FILE.symlink?)

    info = JSON.parse(File.read(INFO_FILE))
    if (info.has_key?("last_command"))
        if (info["last_command"].has_key?("profile"))
            profile = Profile.from_json(info["last_command"]["profile"])
            info["last_command"]["profile"] = profile
        end
    end
    return info
end

def read_zoomrc()
    default_zoomrc if (!RC_FILE.exist? && !RC_FILE.symlink?)

    rc = JSON.parse(File.read(RC_FILE))
    profiles = Hash.new
    rc["profiles"].each do |name, prof|
        profiles[name] = Profile.from_json(prof)
    end
    rc["profiles"] = profiles
    return rc
end

def remove_colors(str)
    return str.unpack("C*").pack("U*").gsub(/\e\[([0-9;]*m|K)/, "")
end

def shortcut_cache(profile)
    return if (!CACHE_FILE.exist?)

    # Open shortcut file for writing
    shct = File.open(SHORTCUT_FILE, "w")

    # Read in cache
    File.open(CACHE_FILE) do |cache|
        start_dir = ""
        file = nil
        filename = ""
        first_time = true
        count = 1

        cache.each do |line|
            line.chomp!
            plain = remove_colors(line)
            if (line.start_with?("ZOOM_EXE_DIR="))
                # Get directory where search was ran
                start_dir = line.gsub("ZOOM_EXE_DIR=", "")
            elsif ((line == "-") || (line == "--") || line.empty?)
                # Ignore dividers when searching with context and
                # empty lines
            elsif (plain.scan(/^[0-9]+[:-]/).empty?)
                operator = profile.operator.split("/").last
                if (operator != "find")
                    if (file != line)
                        # Filename
                        file = line
                        filename = remove_colors(file)

                        puts if (!first_time)
                        first_time = false

                        puts "\e[0m#{file}"
                    end
                else
                    # Operator was find
                    puts "\e[1;31m[#{count}]\e[0m #{line}"
                    shct.write("'#{start_dir}/#{line}'\n")
                    count += 1
                end
            elsif (file)
                # Match
                sanitized = line.unpack("C*").pack("U*")
                    .gsub(/[\u0080-\u00ff]+/, "\1".dump[1..-2])
                puts "\e[1;31m[#{count}]\e[0m #{sanitized}"

                lineno = remove_colors(line).split(/[:-]/)[0]
                shct.write("+#{lineno} '#{start_dir}/#{filename}'\n")

                count += 1
            end
        end
    end
end

def tags_from_cache()
    return if (!CACHE_FILE.exist?)

    # Open shortcut file for writing
    shct = File.open(SHORTCUT_FILE, "r")

    # Read in cache
    File.open(CACHE_FILE) do |cache|
        count = 1

        cache.each do |line|
            line.chomp!
            plain = remove_colors(line)
            if (line.start_with?("ZOOM_EXE_DIR="))
                # Ignore this line
            elsif ((line == "-") || (line == "--") || line.empty?)
                # Ignore dividers when searching with context and
                # empty lines
            elsif (plain.scan(/^[0-9]+[:-]/).empty?)
                if (!plain.scan(/^\.\//).empty?)
                    # Operator was probably find
                    puts count
                    count += 1
                end
            else
                puts count
                count += 1
            end
        end
    end
end

def write_zoominfo(info)
    File.open(INFO_FILE, "w") do |file|
        file.write(JSON.pretty_generate(info))
    end
end

def write_zoomrc(rc)
    File.open(RC_FILE, "w") do |file|
        file.write(JSON.pretty_generate(rc))
    end
end

# Load custom profiles
custom_profiles = Pathname.new("~/.ZoomProfiles.rb").expand_path
if (custom_profiles.exist?)
    require_relative custom_profiles
end

# Global variables
CACHE_FILE = Pathname("~/.zoom_cache").expand_path
INFO_FILE = Pathname("~/.zoominfo").expand_path
PAGER = "#{File.expand_path($0)} --pager"
RC_FILE = Pathname("~/.zoomrc").expand_path
SHORTCUT_FILE = Pathname("~/.zoom_shortcuts").expand_path

# Parse cli args and read in rc file
info = read_zoominfo
options = parse(ARGV, info["last_command"]["profile"])
rc = read_zoomrc

# Get info from rc
if (options.has_key?("use"))
    # Override current profile
    prof_name = options["use"]
    if (!rc["profiles"].has_key?(prof_name))
        puts "Profile \"#{prof_name}\" does not exist!"
        exit ZoomExit::PROFILE_DOES_NOT_EXIST
    end
else
    prof_name = info["profile"]
end
profile = rc["profiles"][prof_name]

# Get executables
editor = rc["editor"]
editor = find_in_path(ENV["EDITOR"]) if (editor.empty?)
editor = find_in_path("vim") if (editor.nil? || editor.empty?)
operator = profile["operator"]

# Make sure executables are found
if (!editor)
    puts "Editor command \"#{rc["editor"]}\" was not found!"
elsif (!operator)
    puts "Operator command \"#{profile["operator"]}\" was not found!"
end

# Main
if (options["pager"])
    File.open(CACHE_FILE, "w") do |f|
        f.write("ZOOM_EXE_DIR=#{Dir.pwd}\n")
        $stdin.each_line do |line|
            f.write(line)
        end
    end
elsif (options["repeat"])
    if (info.has_key?("last_command"))
        if (info["last_command"].has_key?("profile"))
            # Search and save results
            exe_command(
                info["last_command"]["profile"],
                info["last_command"]["subargs"],
                info["last_command"]["pattern"]
            )
        end
    end
elsif (options.has_key?("go"))
    # If passing in search result tags, open them in editor
    tags = parse_tags(options["go"])
    exit ZoomExit::GOOD if (tags.empty?)

    # Open first result with no prompt
    tag = tags.delete_at(0)
    open_editor_to_result(editor, tag)

    # Open remaining results with prompts
    tags.each do |tag|
        print "Do you want to open result #{tag} [y]/n/q/l?: "

        answer = nil
        while (!answer)
            begin
                system("stty raw -echo")
                if $stdin.ready?
                    answer = $stdin.getc.chr
                else
                    sleep 0.1
                end
            ensure
                system("stty -raw echo")
            end
        end
        puts

        case answer
        when "n", "N"
            # Do nothing
        when "l", "L"
            # Open this result, then exit
            open_editor_to_result(editor, tag)
            exit ZoomExit::GOOD
        when "q", "Q", "\x03"
            # Quit or ^C
            exit ZoomExit::GOOD
        else
            # Do nothing
            open_editor_to_result(editor, tag)
        end
    end
elsif (options.has_key?("add"))
    # Add a new profile
    prof = options["add"]

    if (rc["profiles"].has_key?(prof))
        puts "Profile \"#{prof}\" already exists!"
        exit ZoomExit::PROFILE_ALREADY_EXISTS
    end

    rc["profiles"][prof] = add_profile
    write_zoomrc(rc)
elsif (options.has_key?("delete"))
    # Delete an existing profile
    prof = options["delete"]

    info["profile"] = "default" if (prof_name == prof)

    if (prof != "default")
        if (prof != "zoom_find")
            rc["profiles"].delete(prof)
            write_zoominfo(info)
            write_zoomrc(rc)
        else
            puts "You can't delete the zoom_find profile!"
        end
    else
        puts "You can't delete the default profile!"
    end
elsif (options.has_key?("edit"))
    # Edit profile
    prof = options["edit"]

    if (!rc["profiles"].has_key?(prof))
        puts "Profile \"#{prof}\" doesn't exist!"
        exit ZoomExit::PROFILE_DOES_NOT_EXIST
    end

    if (prof == "zoom_find")
        puts "You can't modify the zoom_find profile!"
        exit ZoomExit::CAN_NOT_MODIFY_PROFILE
    end

    clas = rc["profiles"][prof].class.to_s

    puts "Enter class (default #{clas}):"

    new_clas = gets.chomp
    puts if (!new_clas.nil? && !new_clas.empty?)

    new_clas = clas if (new_clas.nil? || new_clas.empty?)
    if (new_clas != clas)
        begin
            # Not sure if I really want to overwrite flags, prepend,
            # and append but I think it's safer for now
            rc["profiles"][prof] = Object::const_get(new_clas).new
        rescue NameError => e
            puts "Unknown Profile class #{new_clas}!"
            exit ZoomExit::UNKNOWN_PROFILE_CLASS
        end
    end

    edit_profile(rc["profiles"][prof])
    write_zoomrc(rc)
elsif (options.has_key?("editor"))
    if (options["editor"].empty?)
        ed = ""
    else
        ed = find_in_path(options["editor"])
    end
    if (ed)
        rc["editor"] = ed
        write_zoomrc(rc)
    else
        puts "Editor #{options["editor"]} was not found!"
    end
elsif (options.has_key?("list"))
    # List the profiles
    rc["profiles"].keys.sort.each do |name|
        if (prof_name == name)
            puts "### \e[32m#{name}\e[0m ###"
        else
            puts "### #{name} ###"
        end
        puts rc["profiles"][name].info
        puts
    end
elsif (options.has_key?("list-profile-names"))
    # List the profile names
    rc["profiles"].keys.sort.each do |name|
        puts name
    end
elsif (options.has_key?("list-tags"))
    tags_from_cache
elsif (options.has_key?("rename"))
    # Rename the current profile
    prof = options["rename"]
    if (prof_name == "default")
        puts "You can't rename the default profile!"
    elsif (prof_name == "zoom_find")
        puts "You can't rename the zoom_find profile!"
    elsif (rc["profiles"].has_key?(prof))
        puts "Profile \"#{prof}\" already exists!"
    elsif (prof_name != prof)
        info["profile"] = prof if (info["profile"] == prof_name)
        rc["profiles"][prof] = rc["profiles"][prof_name]
        rc["profiles"].delete(prof_name)
        write_zoominfo(info)
        write_zoomrc(rc)
    end
elsif (options.has_key?("switch"))
    # Switch profiles
    prof = options["switch"]
    if (rc["profiles"].has_key?(prof))
        info["profile"] = prof
        write_zoominfo(info)
    else
        puts "Profile \"#{prof}\" does not exist!"
    end
elsif (options["which"])
    puts "### \e[32m#{prof_name}\e[0m ###"
    puts rc["profiles"][prof_name].info
else
    # Store last command
    info["last_command"] = Hash.new
    info["last_command"]["profile"] = profile
    info["last_command"]["subargs"] = options["subargs"]
    info["last_command"]["pattern"] = options["pattern"]
    write_zoominfo(info)

    # Search and save results
    exe_command(profile, options["subargs"], options["pattern"])
end
