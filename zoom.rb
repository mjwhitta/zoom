#!/usr/bin/env ruby

require "io/wait"
require "json"
require "optparse"
require "pathname"
require "shellwords"

class Profile < Hash
    def flags(flags = nil)
        self["flags"] = flags if (flags)
        return self["flags"]
    end

    def self.from_json(json)
        return Profile.new(json["operator"],
                           json["flags"],
                           json["prepend"])
    end

    def info()
        "Prepend : " + self["prepend"] + "\n" +
        "Operator: " + self["operator"] + "\n" +
        "Flags   : " + self["flags"]
    end

    def initialize(operator, flags = "", env_prepend = "")
        self.operator(operator)
        self.flags(flags)
        self.prepend(env_prepend)
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

    def prepend(env_prepend = nil)
        self["prepend"] = env_prepend if (env_prepend)
        return self["prepend"]
    end

    def to_s()
        [self["prepend"], self["operator"], self["flags"]].join(" ")
    end
end

def default_zoomrc()
    rc = Hash.new
    profs = Hash.new

    # Default ag profiles
    if (find_in_path("ag"))
        ag = Profile.new("ag",
                         "-S --color-match \"47;1;30\" " \
                         "--color-line-number \"0;37\" " \
                         "--ignore *.pdf")
        all = Profile.new("ag",
                         "-uS --color-match \"47;1;30\" " \
                         "--color-line-number \"0;37\"")
    else
        ag = nil
        all = nil
    end

    # Default ack profile
    if (find_in_path("ack"))
        cmd = "ack"
    elsif (find_in_path("ack-grep"))
        cmd = "ack-grep"
    else
        cmd = nil
    end
    if (cmd)
        ack = Profile.new(cmd,
                          "--smart-case",
                          "ACK_COLOR_LINENO=white " \
                          "ACK_COLOR_MATCH=\"black on_white\"")
    else
        ack = nil
    end

    # Default grep profile (emulate ag/ack as much as possible)
    grep = Profile.new("grep",
                       "--color=always -EHIinR " \
                       "--exclude-dir=.bzr --exclude-dir=.git " \
                       "--exclude-dir=.svn",
                       "GREP_COLORS=\"fn=1;32:ln=0;37:" \
                       "ms=47;1;30:mc=47;1;30:sl=:cx=:bn=:se=\"")
    if (!all)
        all = Profile.new("grep",
                          "--color=always -EHinR",
                          "GREP_COLORS=\"fn=1;32:ln=0;37:" \
                          "ms=47;1;30:mc=47;1;30:sl=:cx=:bn=:se=\"")
    end

    # Create default profile
    if (ag)
        default = ag
    elsif (ack)
        default = ack
    else
        default = grep
    end

    # Put profiles into rc
    profs["ack"] = ack if (ack)
    profs["ag"] = ag if (ag)
    profs["all"] = all if (all)
    profs["default"] = default
    profs["grep"] = grep

    # Default editor (use $EDITOR)
    rc["editor"] = ""
    rc["profile"] = "default"
    rc["profiles"] = profs

    # Reset last command to be empty
    rc["last_command"] = Hash.new

    write_zoomrc(rc)
end

def exe_command(profile, args, pattern)
    operator = profile.operator.split("/").last

    case operator
    when "ag", "ack", "ack-grep"
        CACHE_FILE.delete if (CACHE_FILE.exist?)

        if (!pattern.nil? && !pattern.empty?)
            system("#{profile} --pager \"#{PAGER}\" #{args} " \
                   "#{pattern.shellescape}")
        else
            system("#{profile} --pager \"#{PAGER}\" #{args}")
        end

        shortcut_cache
    when "grep"
        CACHE_FILE.delete if (CACHE_FILE.exist?)

        # Emulate ag/ack as much as possible
        if (!pattern.nil? && !pattern.empty?)
            system("#{profile} #{args} #{pattern.shellescape} | " \
                   "sed \"s|\\[K[:-]|\\[K\\n|\" | #{PAGER}")
        else
            system("#{profile} #{args} | " \
                   "sed \"s|\\[K[:-]|\\[K\\n|\" | #{PAGER}")
        end

        shortcut_cache
    else
        system("#{profile} #{pattern}")
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

def is_exe?(cmd)
    exe = Pathname(cmd).expand_path
    return (exe.file? && exe.executable?)
end

def open_editor_to_result(editor, result)
    loc = get_location_of_result(result.to_i)
    if (loc)
        system("#{editor} +#{loc}")
    else
        puts "Invalid tag \"#{result}\"!"
    end
end

def parse(args)
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
                shortcut_cache
            end
            exit
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
            "--editor=EDITOR",
            "Use the specified editor"
        ) do |editor|
            options["editor"] = editor
        end

        opts.on(
            "-f",
            "--flags=FLAGS",
            "Set flags for current profile"
        ) do |flags|
            options["flags"] = flags
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
            exit
        end

        opts.on("-l", "--list", "List profiles") do
            options["list"] = true
        end

        opts.on(
            "-o",
            "--operator=OPERATOR",
            "Set operator for current profile"
        ) do |op|
            options["operator"] = op
        end

        opts.on(
            "--pager",
            "Treate zoom as a pager, for use with ag and ack"
        ) do
            options["pager"] = true
        end

        opts.on(
            "-p",
            "--prepend=PREPEND",
            "Set the prepend string for the current profile"
        ) do |env_prepend|
            options["prepend"] = env_prepend
        end

        opts.on("-r", "--repeat", "Repeat the last zoom command") do
            options["repeat"] = true
        end

        opts.on("--rc", "Create default .zoomrc file") do
            default_zoomrc
            exit
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
            "grep? Good! This tool is for you! zoom adds some " \
            "convenience to ag/ack/grep by allowing you to quickly " \
            "open your search results in your editor of choice. " \
            "When looking at large code-bases, it can be a pain to " \
            "have to scroll to find the filename of each result. " \
            "zoom prints a tag number in front of each result that " \
            "ag/ack/grep outputs. Then you can quickly open that " \
            "tag number with zoom to jump straight to the source. " \
            "zoom is even persistent across all your sessions! You " \
            "can search in one terminal and jump to a tag in " \
            "another terminal from any directory!",
            "",
            "EXAMPLES:",
            "",
            "Add a profile named test:",
            "    $ z --add test",
            "",
            "Change the operator of the current profile:",
            "    $ z --operator grep",
            "",
            "Change the operator of the profile \"test\":",
            "    $ z --use test --operator grep",
            "",
            "Change the flags of the current profile:",
            "    $ z --flags \"--color=always -EHIinR\"",
            "",
            "Change the prepend string of the current profile:",
            "    $ z --prepend \"PATH=/bin\"",
            "    $ z --prepend \"cd /some/path;\"",
            "",
            "Execute the current profile:",
            "    $ z PATTERN",
            "",
            "Repeat the previous zoom command:",
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
        )
    end
    parser.parse!

    case File.basename($0)
    when "zc"
        if (CACHE_FILE.exist? && !CACHE_FILE.directory?)
            shortcut_cache
        end
        exit
    when "zg"
        options["go"] = args[0]
    when "zl"
        options["list"] = true
    when "zr"
        options["repeat"] = true
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

def read_zoomrc()
    default_zoomrc if (!RC_FILE.exist? && !RC_FILE.symlink?)

    rc = JSON.parse(File.read(RC_FILE))
    profiles = Hash.new
    rc["profiles"].each do |name, prof|
        profiles[name] = Profile.from_json(prof)
    end
    rc["profiles"] = profiles
    if (rc.has_key?("last_command"))
        if (rc["last_command"].has_key?("profile"))
            profile = Profile.from_json(rc["last_command"]["profile"])
            rc["last_command"]["profile"] = profile
        end
    end
    return rc
end

def remove_colors(str)
    return str.unpack("C*").pack("U*").gsub(/\e\[([0-9;]*m|K)/, "")
end

def shortcut_cache()
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
                if (file != line)
                    # Filename
                    file = line
                    filename = remove_colors(file)

                    puts if (!first_time)
                    first_time = false

                    puts "\e[0m#{file}"
                end
            elsif (file)
                # Match
                sanitized = line.unpack("C*").pack("U*")
                    .gsub(/[\u0080-\u00ff]+/, "\1".dump[1..-2])
                puts "\e[1;31m[#{count}]\e[0m #{sanitized}"

                lineno = remove_colors(line).split(/[:-]/)[0]
                shct.write("#{lineno} '#{start_dir}/#{filename}'\n")

                count += 1
            end
        end
    end
end

def write_zoomrc(rc)
    File.open(RC_FILE, "w") do |file|
        file.write(JSON.pretty_generate(rc))
    end
end

RC_FILE = Pathname("~/.zoomrc").expand_path
CACHE_FILE = Pathname("~/.zoom_cache").expand_path
SHORTCUT_FILE = Pathname("~/.zoom_shortcuts").expand_path
PAGER = "#{File.expand_path($0)} --pager"

# Parse cli args and read in rc file
options = parse(ARGV)
rc = read_zoomrc

# Get info from rc
if (options.has_key?("use"))
    # Override current profile
    prof_name = options["use"]
    if (!rc["profiles"].has_key?(prof_name))
        puts "Profile \"#{prof_name}\" does not exist!"
        exit
    end
else
    prof_name = rc["profile"]
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

if (options["pager"])
    File.open(CACHE_FILE, "w") do |f|
        f.write("ZOOM_EXE_DIR=#{Dir.pwd}\n")
        $stdin.each_line do |line|
            f.write(line)
        end
    end
elsif (options["repeat"])
    if (rc.has_key?("last_command"))
        if (rc["last_command"].has_key?("profile"))
            # Search and save results
            exe_command(rc["last_command"]["profile"],
                        rc["last_command"]["subargs"],
                        rc["last_command"]["pattern"])
        end
    end
elsif (options.has_key?("go"))
    # If passing in search result tags, open them in editor
    tags = parse_tags(options["go"])

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
            exit
        when "q", "Q", "\x03"
            # Quit or ^C
            exit
        else
            # Do nothing
            open_editor_to_result(editor, tag)
        end
    end
elsif (options.has_key?("add"))
    # Add a new profile
    prof = options["add"]

    if (find_in_path("ag"))
        op = "ag"
    elsif (find_in_path("ack"))
        op = "ack"
    elsif (find_in_path("ack-grep"))
        op = "ack-grep"
    else
        op = "grep"
    end

    if (!rc["profiles"].has_key?(prof))
        rc["profiles"][prof] = Profile.new(op)
        write_zoomrc(rc)
    else
        puts "Profile \"#{prof}\" already exists!"
    end
elsif (options.has_key?("delete"))
    # Delete an existing profile
    prof = options["delete"]

    rc["profile"] = "default" if (prof_name == prof)

    if (prof != "default")
        rc["profiles"].delete(prof)
        write_zoomrc(rc)
    else
        puts "You can't delete the default profile!"
    end
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
elsif (options.has_key?("flags"))
    # Set the flags for the current profile
    rc["profiles"][prof_name].flags(options["flags"])
    write_zoomrc(rc)
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
elsif (options.has_key?("operator"))
    # Set the operator for the current profile
    rc["profiles"][prof_name].operator(options["operator"])
    write_zoomrc(rc)
elsif (options.has_key?("prepend"))
    # Set the prepend string for the current profile
    rc["profiles"][prof_name].prepend(options["prepend"])
    write_zoomrc(rc)
elsif (options.has_key?("rename"))
    # Rename the current profile
    prof = options["rename"]
    if (prof_name == "default")
        puts "You can't rename the default profile!"
    elsif (rc["profiles"].has_key?(prof))
        puts "Profile \"#{prof}\" already exists!"
    elsif (prof_name != prof)
        rc["profile"] = prof if (rc["profile"] == prof_name)
        rc["profiles"][prof] = rc["profiles"][prof_name]
        rc["profiles"].delete(prof_name)
        write_zoomrc(rc)
    end
elsif (options.has_key?("switch"))
    # Switch profiles
    prof = options["switch"]
    if (rc["profiles"].has_key?(prof))
        rc["profile"] = prof
        write_zoomrc(rc)
    else
        puts "Profile \"#{prof}\" does not exist!"
    end
elsif (options["which"])
    puts "### \e[32m#{prof_name}\e[0m ###"
    puts rc["profiles"][prof_name].info
else
    # Store last command
    rc["last_command"] = Hash.new
    rc["last_command"]["profile"] = profile
    rc["last_command"]["subargs"] = options["subargs"]
    rc["last_command"]["pattern"] = options["pattern"]
    write_zoomrc(rc)

    # Search and save results
    exe_command(profile, options["subargs"], options["pattern"])
end
