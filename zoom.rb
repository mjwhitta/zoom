#!/usr/bin/env ruby

require "json"
require "optparse"
require "pathname"

class Profile < Hash
    def flags(flags = nil)
        if (flags)
            self["flags"] = flags
        end
        return self["flags"]
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
        if (env_prepend)
            self["prepend"] = env_prepend
        end
        return self["prepend"]
    end

    def to_s()
        [self["prepend"], self["operator"], self["flags"]].join(" ")
    end
end

RC_FILE = Pathname("~/.zoomrc").expand_path
CACHE_FILE = Pathname("~/.zoom_cache").expand_path
SHORTCUT_FILE = Pathname("~/.zoom_shortcuts").expand_path

def default_zoomrc()
    rc = Hash.new
    profs = Hash.new

    # Default ag profiles
    if (find_in_path("ag"))
        ag = Profile.new("ag",
                         "-S --color-match \"47;1;30\" " \
                         "--color-line-number \"0;37\"")
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

    if (ag)
        default = ag
    elsif (ack)
        default = ack
    else
        default = grep
    end

    # Put profiles into rc
    profs["default"] = default
    if (ag && all)
        profs["ag"] = ag
        profs["all"] = all
    end
    if (ack)
        profs["ack"] = ack
    end
    profs["grep"] = grep

    # Default editor
    editor = find_in_path("vim")
    if (!editor)
        editor = find_in_path("vi")
    end
    rc["editor"] = editor
    rc["profile"] = "default"
    rc["profiles"] = profs

    write_zoomrc(rc)
end

def exe_command(profile, pattern)
    File.open(CACHE_FILE, "w") do |file|
        file.write("ZOOM_EXE_DIR=#{ENV["PWD"]}\n")
    end

    case profile.operator.split("/").last
    when "ag", "ack", "ack-grep"
        system("#{profile} --pager ~/bin/zoom_pager.sh #{pattern}")
        shortcut_cache
    when "grep"
        # Emulate ag/ack as much as possible
        system("#{profile} #{pattern} | sed -e \"s|$|\\n|\" " \
               "-e \"s|:|\\n|\" >> #{CACHE_FILE}")
        shortcut_cache
    else
        system("#{profile} #{pattern}")
    end
end

def find_in_path(cmd)
    if (is_exe?(cmd))
        return cmd
    end

    path = ENV["PATH"].split(":").uniq.delete_if do |i|
        i.empty?
    end
    path.each do |dir|
        if (is_exe?("#{dir}/#{cmd}"))
            return "#{dir}/#{cmd}"
        end
    end
    return nil
end

def is_exe?(cmd)
    exe = Pathname(cmd).expand_path
    return (exe.file? && exe.executable?)
end

def open_editor_to_result(editor, result)
    loc = File.readlines(SHORTCUT_FILE)[result.to_i - 1]
    system("#{editor} +#{loc}")
end

def parse(args)
    options = Hash.new
    parser = OptionParser.new do |opts|
        opts.banner =
            "Usage: #{File.basename($0)} [OPTIONS] <pattern>"

        opts.on("-a",
                "--add=NAME",
                "Add a new profile with specified name") do |profile|
            options["add"] = profile
        end

        opts.on("-c", "--cache", "Show previous results") do
            if (CACHE_FILE.exist? && !CACHE_FILE.directory?)
                shortcut_cache
            end
            exit
        end

        opts.on("-d",
                "--delete=NAME",
                "Delete profile with specified name") do |profile|
            options["delete"] = profile
        end

        opts.on("-f",
                "--flags=FLAGS",
                "Set flags for current profile") do |flags|
            options["flags"] = flags
        end

        opts.on("-g",
                "--go=NUM",
                "Open editor to search result NUM") do |g|
            options["go"] = g
        end

        opts.on("-h", "--help", "Display this help message") do
            puts opts
            exit
        end

        opts.on("-l", "--list", "List profiles") do
            options["list"] = true
        end

        opts.on("-o",
                "--operator=OPERATOR",
                "Set operator for current profile") do |op|
            options["operator"] = op
        end

        opts.on("-p",
                "--prepend=PREPEND",
                "Set the prepend string for the current " \
                "profile") do |env_prepend|
            options["prepend"] = env_prepend
        end

        opts.on("--rc", "Create default .zoomrc file") do
            default_zoomrc
            exit
        end

        opts.on("-r",
                "--rename=NAME",
                "Rename the current profile") do |name|
            options["rename"] = name
        end

        opts.on("-s",
                "--switch=NAME",
                "Switch to profile with specified name") do |profile|
            options["switch"] = profile
        end

        opts.on("-u",
                "--use=NAME",
                "Use specified profile one time only") do |profile|
            options["use"] = profile
        end

        opts.on("-w", "--which", "Display the current profile") do
            options["which"] = true
        end

        opts.on("",
                "zoom allows users to store commands they use " \
                "often in a profile. They can then use or modify " \
                "that profile at any time",
                "",
                "EXAMPLES",
                "",
                "Add a profile named test:",
                "    $ z -a test",
                "",
                "Change the operator of the current profile:",
                "    $ z -o grep",
                "",
                "Change the operator of the profile \"test\":",
                "    $ z -u test -o grep",
                "",
                "Change the flags of the current profile:",
                "    $ z -f \"--color=always -EHIinR\"",
                "",
                "Change the prepend string of the current profile:",
                "    $ z -p \"PATH=/bin\"",
                "",
                "Execute the current profile:",
                "    $ z")
    end
    parser.parse!

    options["pattern"] = args.join(" ")
    return options
end

def read_zoomrc()
    if (!RC_FILE.exist? && !RC_FILE.symlink?)
        default_zoomrc
    end

    rc = JSON.parse(File.read(RC_FILE.expand_path))
    profiles = Hash.new
    rc["profiles"].each do |name, prof|
        op = prof["operator"]
        flags = prof["flags"]
        env_prepend = prof["prepend"]
        profiles[name] = Profile.new(op, flags, env_prepend)
    end
    rc["profiles"] = profiles
    return rc
end

def remove_colors(str)
    return str.gsub(/\e\[([0-9;]*m|K)/, "")
end

def shortcut_cache()
    # Open shortcut file for writing
    shct = File.open(SHORTCUT_FILE, "w")

    # Read in cache
    File.open(CACHE_FILE) do |cache|
        start_dir = ""
        prev_file = nil
        filename = ""
        first_time = true
        count = 1

        cache.each do |line|
            line.chomp!
            if (line.start_with?("ZOOM_EXE_DIR="))
                start_dir = line.split("=")[1]
            elsif (!line.include?(":") && !line.empty?)
                # Filename
                if (prev_file != line)
                    prev_file = line
                    filename = remove_colors(prev_file)
                    if (!first_time)
                        puts
                    end
                    first_time = false
                    puts "\e[0m#{prev_file}"
                end
            elsif (!line.empty?)
                # Match
                if (prev_file)
                    puts "\e[1;31m[#{count}]\e[0m #{line}"

                    lineno = remove_colors(line).split(":")[0]
                    shct.write("#{lineno} #{start_dir}/#{filename}\n")

                    count += 1
                end
            end
        end
        cache.close
    end
    shct.close
end

def write_zoomrc(rc)
    File.open(RC_FILE, "w") do |file|
        file.write(JSON.pretty_generate(rc))
        file.close
    end
end

# Parse cli args and read in rc file
options = parse(ARGV)
rc = read_zoomrc

# Get info from rc
if (options.has_key?("use"))
    # Override current profile
    prof_name = options["use"]
else
    prof_name = rc["profile"]
end
profile = rc["profiles"][prof_name]

# Get executables
editor = rc["editor"]
operator = profile["operator"]

# Make sure executables are found
if (!editor)
    puts "Editor command \"#{rc["editor"]}\" was not found!"
elsif (!operator)
    puts "Operator command \"#{profile["operator"]}\" was not found!"
end

if (options.has_key?("go"))
    # If passing in search result number, open it in editor
    open_editor_to_result(editor, options["go"])
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

    if (prof_name == prof)
        rc["profile"] = "default"
    end

    if (prof != "default")
        rc["profiles"].delete(prof)
        write_zoomrc(rc)
    else
        puts "You can't delete the default profile!"
    end
elsif (options.has_key?("flags"))
    # Set the flags for the current profile
    rc["profiles"][prof_name].flags(options["flags"])
    write_zoomrc(rc)
elsif (options.has_key?("list"))
    # List the profiles
    rc["profiles"].each do |name, prof|
        if (prof_name == name)
            puts "### \e[32m#{name}\e[0m ###"
        else
            puts "### #{name} ###"
        end
        puts "#{prof.info}"
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
        if (rc["profile"] == prof_name)
            rc["profile"] = prof
        end
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
    puts prof_name
else
    # Search and save results
    exe_command(profile, options["pattern"])
end
