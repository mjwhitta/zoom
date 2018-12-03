# Zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### Quickly open CLI search results in your favorite editor!

Do you like to search through code using ag, ack, grep, pt, or rg?
Good! This tool is for you! Zoom adds some convenience to grep-like
search tools by allowing you to quickly open your search results in
your editor of choice. When looking at large code-bases, it can be a
pain to have to scroll to find the filename of each result. Zoom
prints a tag number in front of each result that grep outputs. Then
you can quickly open that tag number with Zoom to jump straight to the
source. Zoom is even persistent across all your sessions! You can
search in one terminal and jump to a tag in another terminal from any
directory!

## How to install

Open a terminal and run the following:

```
$ gem install ruby-zoom
```

Or install from source:

```
$ git clone https://gitlab.com/mjwhitta/zoom.git
$ cd zoom
$ bundle install && rake install
```

### Installation from Distro Packages

#### User Packaged

- ![logo](http://www.monitorix.org/imgs/archlinux.png "arch logo")
  Arch Linux: via [AUR](https://aur.archlinux.org/packages/ruby-zoom)

- Via Firef0x's Arch Linux Repository
  (**[Guide](http://firef0x.github.io/archrepo.html)**)

## Mac users

To use a proper grep, you need to install [homebrew](http://brew.sh)
and then run the following commands before using Zoom:

```
$ brew tap homebrew/dupes
$ brew install grep
$ mkdir -p ~/bin
$ cd ~/bin
$ ln -s $(which ggrep) grep
$ echo "export PATH=~/bin:$PATH" >>~/.bashrc
```

## How to use

You can use Zoom basically the same way you use grep. Use the
following command for more info:

```
$ z --help
```

If you encounter any errors, most Zoom exceptions should be fixable by
running:

```
$ z --rc
```

`WARNING: This resets all your settings!`

If you are still having issues, please create a [GitLab issue].

[GitLab issue]: https://gitlab.com/mjwhitta/zoom/issues

## Shortcuts

Zoom prefixes shortcut tags to search results. If you use Zoom to
search for `eval` in Zoom's `test/test_src/tools` directory, you would
see something like the following:

```
$ z "eval" test/test_src/tools
test/test_src/tools/test.phtml
[1] 11: eval()

test/test_src/tools/test.py
[2] 4: eval()

test/test_src/tools/test.php
[3] 11: eval()

test/test_src/tools/test.php4
[4] 11: eval()

test/test_src/tools/test.js
[5] 3: test.eval()

test/test_src/tools/test.phpt
[6] 11: eval()

test/test_src/tools/test.php5
[7] 11: eval()

test/test_src/tools/test.php3
[8] 11: eval()
```

Now you can jump to result 7 with one of the following commands:

```
$ z --go 7
$ zg 7
```

### Persistent shortcuts

When you perform a search with Zoom, all results are cached. Using one
of the following commands will allow you to see the previous search
results again:

```
$ z --cache
$ zc
```

This means your tags/shortcuts are persistent across all sessions. You
can use other terminals to view your search results or to open them in
an editor.

## Profiles

Profiles allow you to create shortcuts to your favorite commands. Some
profiles are created for you when you first run Zoom. Use one of the
following commands to list your profiles:

```
$ z --list
$ zl
```

These profiles do not need to be limited to grep shortcuts.

Note: The `find` profile is "special" and should return a list of
files or directories.

### Custom profile classes

If you want to create your own custom profile classes, you can simply
define your classes in `~/.config/zoom/`:

```ruby
# list_profile.rb

class ListProfile < Zoom::Profile
    # You can redefine this method if you want, or leave it out to
    # accept the default functionality (shown below).
    # def exe(header)
    #     # Emulate grep
    #     cmd = [
    #         before,
    #         tool,
    #         @format_flags,
    #         flags,
    #         only_exts_and_files,
    #         header["translated"],
    #         header["args"],
    #         "--",
    #         header["regex"].shellescape,
    #         header["paths"],
    #         after
    #     ].join(" ").strip
    #
    #     if (header.has_key?("debug") && header["debug"])
    #         puts cmd
    #         return ""
    #     else
    #         return %x(#{cmd})
    #     end
    # end

    def initialize(
        name = nil,
        tool = nil,
        flags = nil,
        before = nil, # Env vars, such as PATH
        after = nil # Follow up commands or redirection
    )
        after ||= "2>/dev/null"
        flags ||= "--color -AFhl"
        tool ||= "ls"
        super(name, tool, flags, before, after)
    end
end
```

```ruby
# hello_profile.rb

class HelloProfile < Zoom::Profile
    def initialize(
        name = nil,
        tool = nil,
        flags = nil,
        before = nil, # Env vars, such as PATH
        after = nil # Follow up commands or redirection
    )
        after ||= "Hello world!"
        tool ||= "echo"
        super(name, tool, flags, before, after)
    end
end
```

```ruby
# search_profile.rb

class SearchProfile < Zoom::Profile
    def grep_like_format_flags(all = false)
        # Simple grep-like output
        @format_flags = "--color=never -EHInRs"
        @format_flags = "--color=never -aEHnRs" if (all)
        @taggable = true # Tag results (defaults to false)
        # Parse results as grep results (defaults to true)
        @grep_like_tags = true # Set to false for Find profiles
    end

    def initialize(
        name = nil,
        tool = nil,
        flags = nil,
        before = nil, # Env vars, such as PATH
        after = nil # Follow up commands or redirection
    )
        flags ||= "--smart-case-flag"
        tool ||= "some_search_tool"
        super(name, tool, flags, before, after)

        # Only search specified extensions and files
        @exts = ["c", "h"]
        @files = ["Makefile"]
    end

    # Create the necessary flags to only search specified extensions
    # and files
    def only_exts_and_files
        f = Array.new
        @exts.each do |ext|
            f.push("--include=\"*.#{ext}\"")
        end
        @files.each do |file|
            f.push("--include=\"#{file}\"")
        end
        return f.join(" ")
    end

    # Translate the --follow, --ignore, and --word-regexp flags
    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
                when "follow"
                    to.push("--follow")
                when "ignore"
                    to.push("--ignore=#{value}")
                when "word-regexp"
                    to.push("-w")
            end
        end
        return to.join(" ")
    end
end
```

```ruby
# sec_profile.rb

class SecProfile < Zoom::SecurityProfile
    def initialize(
        name = nil,
        tool = nil,
        flags = nil,
        before = nil, # Env vars, such as PATH
        after = nil # Follow up commands or redirection
    )
        tool = Zoom::ProfileManager.default_tool

        # Only need the case statement if you don't want the default
        # flags
        case tool
            when /^ack(-grep)?$/
                flags ||= "ack_flags_here"
            when "ag"
                flags ||= "ag_flags_here"
            when "grep"
                flags ||= "grep_flags_here"
            when "pt"
                flags ||= "pt_flags_here"
            when "rg"
                flags ||= "rg_flags_here"
        end

        super(name, tool, flags, before, after)

        @exts = ["c", "cpp", "h", "hpp"]
        @regex = "(^|\s)popen\("
    end
end
```

## Convenient symlinks

If you find it tedious to use Zoom with the flags, there are currently
5 convience symlinks that are supported.

- `zc` is the same as `z --cache` or `z -c`
- `zf` is the same as `z --find`
- `zg` is the same as `z --go` or `z -g`
- `zl` is the same as `z --list` or `z -l`
- `zr` is the same as `z --repeat` or `z -r`

You can also symlink zoom to a profile name in order to quickly
execute favorite profiles.

```
$ cd ~/bin
$ ln -s z test
$ ./test # same as 'z --use test'
```

## Interested in security?

Zoom allows to you create profiles for all sorts of commands. This may
make Zoom a friendly tool for Penetration Testers or Security
Researchers who are looking for a simple way to store exploits. I've
included some example profiles for searching for hard-coded passwords
or unsafe functions/includes in a handful of languages. These profiles
are not created by default with `z --rc`. To create them run `z
--secprofs`.

These profiles have a hard-coded regex so if you want to change the
regex used, you can run the following command to change the code:

```
$ gem open ruby-zoom
```

Navigate to `lib/zoom/profile` directory and select a profile to make
changes. If you want the revert your changes, run the following
command:

```
$ gem pristine ruby-zoom
```

## Supported editors

Zoom currently works with:

- vim (provides the best zoom experience)
- emacs (looking for some help here, simulate the vim experience)
- nano
- pico
- jpico
- any editor with `+LINE` as an option in it's man page

If you're using Vim as your editor, then you can use `<leader>z` to
open the quickfix window, which will contain a list of the tags you
specified. You can also use `zn` to go to the next tag and `zp` to go
to the previous.

## What is [ag](https://github.com/ggreer/the_silver_searcher)?

ag is a faster version of ack!

## What is [ack](http://betterthangrep.com)?

ack is the replacement for grep!

## What is [pt]?

pt is a code search tool similar to ack and ag!

[pt]: https://github.com/monochromegane/the_platinum_searcher

## What is [rg](https://github.com/BurntSushi/ripgrep)?

rg combines the usability of ag with the raw speed of grep!

## What is [grep](http://en.wikipedia.org/wiki/Grep)?

If you don't know what grep is, this probably isn't the tool for you.
You should learn how to properly use grep before using a tool such as
Zoom which attempts to streamline the process for you.

## ZSH completion function

For some simple zsh completion with Zoom, you can add the following to
your `~/.zshrc`:

```
compdef _gnu_generic z zc zf zg zl zr
```

## Links

- [Source](https://gitlab.com/mjwhitta/zoom)
- [RubyGems](https://rubygems.org/gems/ruby-zoom)

## TODO

- Need to test to see if any passthru flags break functionality
    - In the meantime, profiles have sane default flags
- RDoc
