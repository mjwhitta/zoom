# Zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### Quickly open CLI search results in your favorite editor!

Do you like to search through code using ag, ack, grep, or pt? Good!
This tool is for you! Zoom adds some convenience to ag/ack/grep/pt by
allowing you to quickly open your search results in your editor of
choice. When looking at large code-bases, it can be a pain to have to
scroll to find the filename of each result. Zoom prints a tag number
in front of each result that ag/ack/grep/pt outputs. Then you can
quickly open that tag number with Zoom to jump straight to the source.
Zoom is even persistent across all your sessions! You can search in
one terminal and jump to a tag in another terminal from any directory!

## How to install

Open a terminal and run the following:

```bash
$ gem install ruby-zoom
```

Or install from source:

```bash
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

If using the grep operator, you need to install
[homebrew](http://brew.sh) and then run the following commands before
using Zoom:

```bash
$ brew tap homebrew/dupes
$ brew install grep
$ mkdir -p ~/bin
$ cd ~/bin
$ ln -s $(which ggrep) grep
$ echo "export PATH=~/bin:$PATH" >>~/.bashrc
```

## How to use

You can use Zoom basically the same way you use ag/ack/grep/pt. Try
the following command for more info:

```bash
$ z --help
```

If you encounter any errors, most Zoom exceptions should be fixable by
running:

```bash
$ z --rc
```

`WARNING: This resets all your settings!`

If you are still having issues, please create a [GitLab issue].

[GitLab issue]: https://gitlab.com/mjwhitta/zoom/issues

## Shortcuts

Zoom prefixes shortcut tags to ag/ack/grep/pt's search results! If you
use Zoom to search for "ScoobyDoo" in the Zoom source directory, you
would see something like the following:

```
$ z scoobydoo
Gemfile
[1] 8: gem "scoobydoo"

lib/zoom/profile/ack.rb
[2] 4:        if ((o == "ack") && ScoobyDoo.where_are_you("ack-grep"))

lib/zoom/profile_manager.rb
[3] 2: require "scoobydoo"
[4] 24:             return op if (ScoobyDoo.where_are_you(op))
[5] 33:             if (ScoobyDoo.where_are_you(op))

lib/zoom/profile.rb
[6] 2: require "scoobydoo"
[7] 143:             op = ScoobyDoo.where_are_you(o)

lib/zoom/wish/editor_wish.rb
[8] 2: require "scoobydoo"
[9] 20:         if (ScoobyDoo.where_are_you(args))

lib/zoom/config.rb
[10] 3: require "scoobydoo"
[11] 68:             e = ScoobyDoo.where_are_you(ed)
[12] 76:         e = ScoobyDoo.where_are_you(e)
[13] 77:         e = ScoobyDoo.where_are_you("vi") if (e.nil?)

zoom.gemspec
[14] 33:   s.add_runtime_dependency("scoobydoo", "~> 0.1", ">= 0.1.4")
```

Now you can jump to result 7 with the following commands:

```bash
$ z --go 7
```

If you're using Vim as your editor, then you can use `<leader>z` to
open the quickfix window, which will contain a list of the tags you
specified. You can also use `zn` to go to the next tag and `zp` to go
to the previous.

### Persistent shortcuts

When you perform a search with Zoom, all results are cached. Using the
following commands will allow you to see the previous search results
again:

```bash
$ z --cache
```

This means your tags/shortcuts are persistent across all sessions. You
can use other terminals to view your search results or to open them in
an editor.

## Profiles

Profiles allow you to create shortcuts to your favorite commands. Some
profiles are created for you when you first run Zoom. Use the
following command to list your profiles:

```bash
$ z --list
```

These profiles do not need to be limited to ag/ack/grep/pt shortcuts.

Note: The `find` profile is "special" and should return a list of
files.

### Custom profile classes

If you want to create your own custom profile classes, you can simply
define your classes in `~/.config/zoom/`:

```ruby
# list_profile.rb

class ListProfile < Zoom::Profile
    # You can redefine this method if you want, or leave it out to
    # accept the default functionality.
    # def exe(args, pattern)
    # end

    def initialize(
        name,
        operator = "",
        flags = "",
        before = "", # For use with env vars, such as PATH
        after = "" # For use with follow up commands or redirection
    )
        super(name, "ls", "--color -AFhl", before, "2>/dev/null")
        @taggable = false # Don't tag results
    end
end
```

```ruby
# hello_profile.rb

class HelloProfile < Zoom::Profile
    def initialize(
        name,
        operator = "",
        flags = "",
        before = "", # For use with env vars, such as PATH
        after = "" # For use with follow up commands or redirection
    )
        super(name, "echo", flags, before, "Hello world!")
        @taggable = false # Don't tag results
    end
end
```

```ruby
# search_profile.rb

class SearchProfile < Zoom::Profile
    def initialize(
        name,
        operator = "some_search_tool",
        flags = "--case-insensitive",
        before = "", # For use with env vars, such as PATH
        after = "" # For use with follow up commands or redirection
    )
        super(name, operator, flags, before, after)
        @format_flags = "--color=never -EHInRs" # Mirror grep output
        @taggable = true
    end

    def translate(from)
        to = Array.new
        from.each do |flag, value|
            case flag
                when "ignore"
                    # Translate to ignore flag for this operator
                    to.push("--ignore=#{value}")
                when "word-regexp"
                    # Translate to word-regexp flag for this operator
                    to.push("-w")
            end
        end
        return to.join(" ")
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

```bash
$ cd ~/bin
$ ln -s z test
$ ./test # same as 'z --use test'
```

## Interested in security?

Zoom allows to you create profiles for commands other than
ag/ack/grep/pt. This may make Zoom a friendly tool for Penetration
Testers or Security Researchers who are looking for a simple way to
store exploits. I've included some example profiles for searching for
hard-coded passwords or unsafe C/Java/Javascript/PHP/Python code.
These profiles are not created by default with `z --rc`. To create
them run `z --secprofs`.

These profiles have a hard-coded pattern so if you want to change the
regex used, you can run the following command to change the code:

```bash
$ gem open ruby-zoom
```

Navigate to `lib/zoom/profile` directory and select a profile to make
changes. If you want the revert your changes, run the following
command:

```bash
$ gem pristine ruby-zoom
```

## Supported editors

Zoom currently works with:

- vim (provides the best zoom experience)
- emacs
- nano
- pico
- jpico
- any editor with `+LINE` as an option in it's man page

## What is [ag](https://github.com/ggreer/the_silver_searcher)?

ag is a faster version of ack!

## What is [ack](http://betterthangrep.com)?

ack is the replacement for grep!

## What is [pt](https://github.com/monochromegane/the_platinum_searcher)?

pt is a code search tool similar to ack and ag!

## What is [grep](http://en.wikipedia.org/wiki/Grep)?

If you don't know what grep is, this probably isn't the tool for you.
You should learn how to properly use grep before using a tool such as
Zoom which attempts to streamline the process for you.

## ZSH completion function

For some simple zsh completion with Zoom, you can add the following to
your `~/.zshrc`:

```bash
compdef _gnu_generic z zc zf zg zl zr
```

## Links

- [Homepage](https://mjwhitta.github.io/zoom)
- [Source](https://gitlab.com/mjwhitta/zoom)
- [Mirror](https://github.com/mjwhitta/zoom)
- [RubyGems](https://rubygems.org/gems/ruby-zoom)

## TODO

- Need to test to see if any ag/ack/grep flags break functionality
    - In the meantime, Ag/Ack/Grep/Pt profiles have sane default flags
- RDoc
