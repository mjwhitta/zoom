# Zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### Quickly open CLI search results in your favorite editor!

Do you like to search through code using ag, ack, or grep? Good! This
tool is for you! Zoom adds some convenience to ag/ack/grep by allowing
you to quickly open your search results in your editor of choice. When
looking at large code-bases, it can be a pain to have to scroll to
find the filename of each result. Zoom prints a tag number in front of
each result that ag/ack/grep outputs. Then you can quickly open that
tag number with Zoom to jump straight to the source. Zoom is even
persistent across all your sessions! You can search in one terminal
and jump to a tag in another terminal from any directory!

## How to install

Open a terminal and run the following:

```bash
$ gem install ruby-zoom
```

Or install from source:

```bash
$ git clone https://gitlab.com/mjwhitta/zoom.git
$ cd zoom
$ rake install
```

### Installation from Distro Packages

#### User Packaged

Note: These are likely broken since Zoom 3.0!

- ![logo](http://www.monitorix.org/imgs/archlinux.png "arch logo")
   Arch Linux: in the
   [AUR](https://aur.archlinux.org/packages/zoom-git)

- [Firef0x's](http://firef0x.github.io/archrepo.html) Arch Linux
   Repository

## Mac users

If using the grep operator, you need to install
[homebrew](http://brew.sh) and then run the following commands before
using Zoom:

```bash
$ brew install gnu-sed grep
$ mkdir -p ~/bin
$ cd ~/bin
$ ln -s $(which gsed) sed
$ ln -s $(which ggrep) grep
```

## How to use

```bash
$ z --help
Usage: z [OPTIONS] <pattern>
    -a, --add=NAME                   Add a new profile with specified name
    -c, --cache                      Show previous results
    -d, --delete=NAME                Delete profile with specified name
    -e, --edit=NAME                  Edit profile with specified name
        --editor=EDITOR              Use the specified editor
        --examples                   Show some examples
        --find                       Use the zoom_find profile
    -g, --go=NUM                     Open editor to search result NUM
    -h, --help                       Display this help message
    -l, --list                       List profiles
        --list-profile-names         List profile names for completion functions
        --list-tags                  List tags for completion functions
        --pager                      Treat Zoom as a pager (internal use only)
    -r, --repeat                     Repeat the last Zoom command
        --rc                         Create default .zoomrc file
        --rename=NAME                Rename the current profile
    -s, --switch=NAME                Switch to profile with specified name
    -u, --use=NAME                   Use specified profile one time only
    -w, --which                      Display the current profile
```

You can use Zoom basically the same way you use ag/ack/grep. If you
encounter any errors, most Zoom exceptions should be fixable by
running:

```bash
$ z --rc
```

If you are still having issues, please create a GitLab issue.

## Shortcuts

Zoom prefixes shortcut tags to ag/ack/grep's search results! If you
use Zoom to search for "ScoobyDoo" in the Zoom source directory, you
would see something like the following:

```bash
$ z ScoobyDoo
lib/zoom.rb
[1] 25:        if (ScoobyDoo.where_are_you("ag"))
[2] 27:        elsif (ScoobyDoo.where_are_you("ack"))
[3] 29:        elsif (ScoobyDoo.where_are_you("ack-grep"))
[4] 73:        e = ScoobyDoo.where_are_you(editor)
[5] 107:        if (ScoobyDoo.where_are_you("ag"))
[6] 117:            ScoobyDoo.where_are_you("ack") ||
[7] 118:            ScoobyDoo.where_are_you("ack-grep")
[8] 203:        op = ScoobyDoo.where_are_you(gets.chomp)
[9] 303:        @editor = ScoobyDoo.where_are_you(@editor)
[10] 304:        @editor = ScoobyDoo.where_are_you("vi") if (@editor.nil?)

lib/zoom_profile.rb
[11] 65:            op = ScoobyDoo.where_are_you(operator)
[12] 69:                self["operator"] = ScoobyDoo.where_are_you("echo")

lib/ack_profile.rb
[13] 33:        if (ScoobyDoo.where_are_you("ack"))
[14] 35:        elsif (ScoobyDoo.where_are_you("ack-grep"))
```

Now you can jump to result 9 with the following command:

```bash
$ z --go 9
```

### Persistent shortcuts

When you perform a search with Zoom, all results are cached. Using the
following command will allow you to see the previous search results
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

These profiles do not need to be limited to ag/ack/grep shortcuts.

Note: The `default` profile is special and can't be deleted. You can
however modify it.

Note: The `zoom_find` profile is special and can't be deleted or
modified.

### Custom profile classes

If you want to create your own custom profile classes, you can simply
define your classes in `~/.zoom_profiles.rb`:

```ruby
require "zoom"

class ListProfile < Zoom::Profile
    # You can redefine this method if you want, or leave it out to
    # accept the default functionality.
    # def exe(args, pattern)
    # end

    def initialize(
        operator = "ls",
        flags = "--color -AFhl",
        envprepend = "",
        append = ""
    )
        super(operator, flags, envprepend, append)
        @taggable = false # Don't tag results
    end
end

class HelloProfile < Zoom::Profile
    def initialize(
        operator = "echo",
        flags = "",
        envprepend = "",
        append = "\"Hello, world!\""
    )
        super(operator, flags, envprepend, append)
        @immutable = true # Don't allow profile changes
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

## Penetration testing

Zoom allows to you create profiles for commands other than
ag/ack/grep. This may make Zoom a friendly tool for Penetration
Testers or Security Researchers who are looking for a simple way to
store exploits. I've included a profile for searching for hard-coded
passwords. The passwords profile is immutable so if you want to change
the regex used, you can run the following command to change the code:

```bash
$ gem open ruby-zoom
```

Navigate to `lib/zoom/profile/passwords.rb` to make changes. If you
want the revert your changes, run the following command:

```bash
$ gem pristine ruby-zoom
```

## Supported editors

Zoom currently works with:

- vim
- emacs
- nano
- pico
- jpico
- any editor with `+LINE` as an option in it's man page

## What is [ag](https://github.com/ggreer/the_silver_searcher)?

ag is a faster version of ack!

## What is [ack](http://betterthangrep.com)?

ack is the replacement for grep!

## What is [grep](http://en.wikipedia.org/wiki/Grep)?

If you don't know what grep is, this probably isn't the tool for you.
You should learn how to properly use grep before using a tool such as
Zoom which attempts to streamline the process for you.

## ZSH completion function

For some simple zsh completion with Zoom, you can add the following to
your `~/.zshrc`:

```bash
fpath=(/path/to/zoom/repo/completions $fpath)
```

You may need to run the following command to update your completion
functions:

```bash
$ rm -f ~/.zcompdump; compinit
```

## Links

- [Homepage](http://mjwhitta.github.io/zoom)
- [Source](https://gitlab.com/mjwhitta/zoom)
- [Mirror](https://github.com/mjwhitta/zoom)
- [RubyGems](https://rubygems.org/gems/ruby-zoom)

## TODO

- [ ] Need to test to see if any ag/ack/grep flags break functionality
- [ ] Make comments/documentation more thorough
