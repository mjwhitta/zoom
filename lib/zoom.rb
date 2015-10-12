require "io/wait"
require "json"
require "pathname"
require "singleton"
require "string"

class Zoom
    include Singleton

    @@cache_file = Pathname.new("~/.zoom_cache").expand_path
    @@info_file = Pathname.new("~/.zoominfo").expand_path
    @@rc_file = Pathname.new("~/.zoomrc").expand_path
    @@shortcut_file = Pathname.new("~/.zoom_shortcuts").expand_path

    def add_profile(
        name,
        clas,
        operator = nil,
        flags = nil,
        envprepend = nil,
        append = nil
    )
        if (@profiles.has_key?(name))
            raise Zoom::ProfileAlreadyExistsError.new(name)
        end

        default_class = nil
        begin
            default_class = Zoom::Profile.profile_by_name(clas).new
        rescue NameError => e
            raise Zoom::ProfileClassUnknownError.new(clas)
        end

        edit_profile(
            name,
            default_class,
            operator,
            flags,
            envprepend,
            append
        )
    end

    def clear_cache
        @@cache_file.delete if (@@cache_file.exist?)
    end

    def configure_editor(editor)
        e = ScoobyDoo.where_are_you(editor)
        if (e.nil?)
            raise Zoom::ExecutableNotFoundError.new(editor)
        end

        @rc["editor"] = e
        write_zoomrc
    end

    def self.default
        default_zoominfo
        default_zoomrc
    end

    def self.default_zoominfo
        info = Hash.new
        info["profile"] = "default"

        # Reset last command to be empty
        info["last_command"] = Hash.new

        File.open(@@info_file, "w") do |file|
            file.write(JSON.pretty_generate(info))
        end
    end

    def self.default_zoomrc
        rc = Hash.new
        profiles = Hash.new

        all = nil

        # Default ag profiles
        if (ScoobyDoo.where_are_you("ag"))
            ag = Zoom::Profile::Ag.new
            all = Zoom::Profile::Ag.new(nil, "-uS")
        else
            ag = nil
        end

        # Default ack profile
        if (
            ScoobyDoo.where_are_you("ack") ||
            ScoobyDoo.where_are_you("ack-grep")
        )
            ack = Zoom::Profile::Ack.new
        else
            ack = nil
        end

        # Default grep profile (emulate ag/ack as much as possible)
        grep = Zoom::Profile::Grep.new
        if (all.nil?)
            all = Zoom::Profile::Grep.new
            all.flags("--color=always -EHinR")
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
        find = Zoom::Profile::Find.new

        # Put profiles into rc
        profiles["ack"] = ack if (ack)
        profiles["ag"] = ag if (ag)
        profiles["all"] = all if (all)
        profiles["default"] = default
        profiles["grep"] = grep
        profiles["passwords"] = Zoom::Profile::Passwords.new
        profiles["zoom_find"] = find
        rc["profiles"] = profiles

        # Default editor (use $EDITOR)
        rc["editor"] = ""

        File.open(@@rc_file, "w") do |file|
            file.write(JSON.pretty_generate(rc))
        end
    end

    def delete_profile(name)
        if (!@profiles.has_key?(name))
            raise Zoom::ProfileDoesNotExistError.new(name)
        end

        if ((name == "default") || @profiles[name].immutable)
            raise Zoom::ProfileCanNotBeModifiedError.new(name)
        end

        @profiles.delete(name)
        write_zoomrc

        if (name == @info["profile"])
            @info["profile"] = "default"
            write_zoominfo
        end
    end

    def edit_profile(
        name,
        profile = nil,
        operator = nil,
        flags = nil,
        envprepend = nil,
        append = nil
    )
        profile = @profiles[name] if (profile.nil?)

        if (profile.nil?)
            raise Zoom::ProfileDoesNotExistsError.new(name)
        end

        if (profile.immutable)
            raise Zoom::ProfileCanNotBeModifiedError.new(name)
        end

        profile.operator(operator) if (operator)
        profile.flags(flags) if (flags)
        profile.prepend(envprepend) if (envprepend)
        profile.append(append) if (append)

        @profiles[name] = profile
        write_zoomrc
    end

    def exec_profile(name, args, pattern)
        name = @info["profile"] if (name.nil?)

        if (!@profiles.has_key?(name))
            raise Zoom::ProfileDoesNotExistError.new(name)
        end

        @info["last_command"] = {
            "profile" => name,
            "subargs" => args.nil? ? "": args,
            "pattern" => pattern.nil? ? "" : pattern
        }
        write_zoominfo

        profile = @profiles[name]
        begin
            clear_cache if (profile.taggable)
            profile.exe(args, pattern)
            shortcut_cache(profile) if (profile.taggable)
        rescue Interrupt
            # ^C
        end
    end

    def get_location_of_result(result)
        count = 0
        File.open(@@shortcut_file) do |file|
            file.each do |line|
                count += 1
                if (count == result)
                    return line
                end
            end
        end
        return nil
    end
    private :get_location_of_result

    def get_new_value(val, default)
        return default if (val.nil? || val.empty?)
        return "" if (val.downcase == "empty")
        return "" if (val.downcase == "\"empty\"")
        return val
    end
    private :get_new_value

    def initialize
        # Load custom profiles
        custom_profs = Pathname.new("~/.zoom_profiles.rb").expand_path
        require_relative custom_profs if (custom_profs.exist?)

        read_zoomrc
        read_zoominfo

        # Setup editor
        @editor = @rc["editor"]
        @editor = ENV["EDITOR"] if (@editor.nil? || @editor.empty?)
        @editor = "vim" if (@editor.nil? || @editor.empty?)
        @editor = ScoobyDoo.where_are_you(@editor)
        @editor = ScoobyDoo.where_are_you("vi") if (@editor.nil?)
    end

    def interactive_add_profile(name)
        if (@profiles.has_key?(name))
            raise Zoom::ProfileAlreadyExistsError.new(name)
        end

        default_op = "grep"
        if (ScoobyDoo.where_are_you("ag"))
            default_op = "ag"
        elsif (ScoobyDoo.where_are_you("ack"))
            default_op = "ack"
        elsif (ScoobyDoo.where_are_you("ack-grep"))
            default_op = "ack-grep"
        end

        ack_class = Zoom::Profile::Ack.to_s
        ag_class = Zoom::Profile::Ag.to_s
        grep_class = Zoom::Profile::Grep.to_s

        case default_op
        when "ack", "ack-grep"
            puts "Enter class (default #{ack_class}):"
        when "ag"
            puts "Enter class (default #{ag_class}):"
        when "grep"
            puts "Enter class (default #{grep_class}):"
        end

        clas = gets.chomp
        puts if (clas && !clas.empty?)

        case default_op
        when "ack", "ack-grep"
            clas = ack_class if (clas.nil? || clas.empty?)
        when "ag"
            clas = ag_class if (clas.nil? || clas.empty?)
        when "grep"
            clas = grep_class if (clas.nil? || clas.empty?)
        end

        add_profile(name, clas)
        interactive_edit_profile(name)
    end

    def interactive_edit_profile(name, profile = nil)
        profile = @profiles[name] if (profile.nil?)

        if (profile.nil?)
            raise Zoom::ProfileDoesNotExistError.new(name)
        end

        if (profile.immutable)
            raise Zoom::ProfileCanNotBeModifiedError.new(name)
        end

        # Get new operator
        puts "Enter operator (default #{profile.operator}):"

        op = ScoobyDoo.where_are_you(gets.chomp)
        puts if (op && !op.empty?)
        op = profile.operator if (op.nil? || op.empty?)

        # Get new flags
        puts "For empty string put \"empty\""
        puts "Enter flags (default \"#{profile.flags}\"):"

        flags = gets.chomp
        puts if (flags && !flags.empty?)
        flags = get_new_value(flags, profile.flags)

        # Get new prepend
        puts "For empty string put \"empty\""
        puts "Enter prepend (default \"#{profile.prepend}\"):"

        envprepend = gets.chomp
        puts if (envprepend && !envprepend.empty?)
        envprepend = get_new_value(envprepend, profile.prepend)

        # Get new append
        puts "For empty string put \"empty\""
        puts "Enter append (default \"#{profile.append}\"):"

        append = gets.chomp
        puts if (append && !append.empty?)
        append = get_new_value(append, profile.append)

        edit_profile(name, profile, op, flags, envprepend, append)
    end

    def list_profile_names
        @profiles.keys.sort.each do |name|
            puts name
        end
    end

    def list_profiles
        @profiles.keys.sort.each do |name|
            if (name == @info["profile"])
                puts "### #{name} ###".green
            else
                puts "### #{name} ###"
            end
            puts @profiles[name].info
            puts
        end
    end

    def list_tags
        return if (!@@cache_file.exist?)

        # Open shortcut file for writing
        shct = File.open(@@shortcut_file, "r")

        # Read in cache
        File.open(@@cache_file) do |cache|
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

    def loop_through_results(results)
        tags = parse_tags(results)
        return if (tags.empty?)

        tag = tags.delete_at(0)
        open_editor_to_result(tag)

        tags.each do |tag|
            print "Do you want to open result #{tag} [y]/n/q/l?: "

            answer = nil
            while (answer.nil?)
                begin
                    system("stty raw -echo")
                    if ($stdin.ready?)
                        answer = $stdin.getc
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
                # Open this result then exit
                open_editor_to_result(tag)
                return
            when "q", "Q", "\x03"
                # Quit or ^C
                return
            else
                open_editor_to_result(tag)
            end
        end
    end

    def open_editor_to_result(result)
        loc = get_location_of_result(result.to_i)
        if (loc)
            system("#{@editor} #{loc}")
        else
            puts "Invalid tag \"#{result}\"!"
        end
    end
    private :open_editor_to_result

    def pager
        File.open(@@cache_file, "w") do |f|
            f.write("ZOOM_EXE_DIR=#{Dir.pwd}\n")
            begin
                $stdin.each_line do |line|
                    f.write(line)
                end
            rescue Interrupt
                # ^C
            end
        end
    end

    def parse_tags(results)
        tags = Array.new
        results.split(",").each do |num|
            if (!num.scan(/^[0-9]+$/).empty?)
                tags.push(num.to_i)
            elsif (!num.scan(/^[0-9]+-[0-9]+$/).empty?)
                range = num.split("-")
                (range[0].to_i..range[1].to_i).each do |i|
                    tags.push(i)
                end
            else
                puts "Tag #{num} not formatted properly. Ignoring."
            end
        end
        return tags
    end
    private :parse_tags

    def read_zoominfo
        if (!@@info_file.exist? && !@@info_file.symlink?)
            default_zoominfo
        end

        @info = JSON.parse(File.read(@@info_file))
    end
    private :read_zoominfo

    def read_zoomrc
        default_zoomrc if (!@@rc_file.exist? && !@@rc_file.symlink?)

        @rc = JSON.parse(File.read(@@rc_file))
        @profiles = Hash.new
        @rc["profiles"].each do |name, prof|
            @profiles[name] = Zoom::Profile.from_json(prof)
        end
        @rc["profiles"] = @profiles
    end
    private :read_zoomrc

    def rename_profile(rename, name = nil)
        name = @info["profile"] if (name.nil?)

        if ((name == "default") || (name == "zoom_find"))
            raise Zoom::ProfileCanNotBeModifiedError.new(name)
        end

        if (!@profiles.has_key?(name))
            raise Zoom::ProfileDoesNotExistError.new(name)
        end

        if (@profiles.has_key?(rename))
            raise Zoom::ProfileAlreadyExistsError.new(rename)
        end

        @profiles[rename] = @profiles[name]
        @profiles.delete(name)
        write_zoomrc

        if (name == @info["profile"])
            @info["profile"] = rename
            write_zoominfo
        end
    end

    def repeat
        return if (@info["last_command"].empty?)

        exec_profile(
            @info["last_command"]["profile"],
            @info["last_command"]["subargs"],
            @info["last_command"]["pattern"]
        )
    end

    def remove_colors(str)
        str.unpack("C*").pack("U*").gsub(/\e\[([0-9;]*m|K)/, "")
    end
    private :remove_colors

    def shortcut_cache(profile = nil)
        return if (!@@cache_file.exist?)
        return if (@info["last_command"].empty?)

        if (profile.nil?)
            profile = @profiles[@info["last_command"]["profile"]]
        end

        # Open shortcut file for writing
        shct = File.open(@@shortcut_file, "w")

        # Read in cache
        File.open(@@cache_file) do |cache|
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
                    shct.write(
                        "+#{lineno} '#{start_dir}/#{filename}'\n"
                    )

                    count += 1
                end
            end
        end
    end

    def show_current
        puts "### #{@info["profile"]} ###".green
        puts @profiles[@info["profile"]].info
    end

    def switch_profile(name)
        if (!@profiles.has_key?(name))
            raise Zoom::ProfileDoesNotExistError.new(name)
        end

        @info["profile"] = name
        write_zoominfo
    end

    def write_zoominfo
        File.open(@@info_file, "w") do |file|
            file.write(JSON.pretty_generate(@info))
        end
    end
    private :write_zoominfo

    def write_zoomrc
        @rc["profiles"] = @profiles
        File.open(@@rc_file, "w") do |file|
            file.write(JSON.pretty_generate(@rc))
        end
    end
    private :write_zoomrc
end

require "zoom/error"
require "zoom/executable_not_found_error"
require "zoom/profile"
require "zoom/profile_already_exists_error"
require "zoom/profile_can_not_be_modified_error"
require "zoom/profile_class_unknown_error"
require "zoom/profile_does_not_exist_error"
require "zoom/profile/ack"
require "zoom/profile/ag"
require "zoom/profile/find"
require "zoom/profile/grep"
require "zoom/profile/passwords"
