# zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### A faster way to use ag/ack/grep

zoom acts as a wrapper for ag/ack/grep or any command really. The goal
was to provide convenience when searching through code-bases via the
CLI.

![Example usage](https://bitbucket.org/mjwhitta/zoom/raw/master/zoom.gif)

## What is [ag](https://github.com/ggreer/the_silver_searcher)?

ag is a faster version of ack!

Click the link above, to learn more about ag, and how to install it.

## What is [ack](http://betterthangrep.com)?

ack is the replacement for grep!

## How to install

Open a terminal and run the following:

```bash
$ git clone https://bitbucket.org/mjwhitta/zoom
$ cd zoom
$ ./install_zoom.sh
```

## How to use

```bash
$ z -h
```

You can use zoom exactly the same way you use ag/ack.

## Shortcuts

zoom prefixes shortcut tags to ag/ack/grep's search results

```bash
$ z def
zoom.rb
[TAG#] 8:    def flags(flags = nil)
[TAG#] 15:    def info()
[TAG#] 21:    def initialize(operator, flags = "", env_prepend = "")
[TAG#] 27:    def operator(operator = nil)
[TAG#] 39:    def prepend(env_prepend = nil)
[TAG#] 46:    def to_s()
[TAG#] 55:def default_zoomrc()
[TAG#] 59:    # Default ag profiles
[TAG#] 72:    # Default ack profile
[TAG#] 89:    # Default grep profile (emulate ag/ack as much as possible)
[TAG#] 98:        default = ag
[TAG#] 100:        default = ack
[TAG#] 102:        default = grep
[TAG#] 106:    profs["default"] = default
[TAG#] 116:    # Default editor
[TAG#] 122:    rc["profile"] = "default"
[TAG#] 128:def exe_command(profile, pattern)
[TAG#] 147:def find_in_path(cmd)
[TAG#] 163:def is_exe?(cmd)
[TAG#] 168:def open_editor_to_result(editor, result)
[TAG#] 173:def parse(args)
[TAG#] 232:        opts.on("--rc", "Create default .zoomrc file") do
[TAG#] 233:            default_zoomrc
[TAG#] 261:def read_zoomrc()
[TAG#] 263:        default_zoomrc
[TAG#] 278:def remove_colors(str)
[TAG#] 282:def shortcut_cache()
[TAG#] 326:def write_zoomrc(rc)
[TAG#] 385:        rc["profile"] = "default"
[TAG#] 388:    if (prof != "default")
[TAG#] 392:        puts "You can't delete the default profile!"
```

Now you can jump to a search result by typing:

```bash
$ z -g TAG#
```

This will cause zoom to open the search result in vim/emacs (currently
the only supported editors)

### Persistent shortcuts

When you perform a search with zoom, all results are cached. Using the
following command will allow you to see the previous search results
again:

```bash
$ z -c
```

This also means you can use other terminals to view your search
results or to open them in an editor.

## Profiles

Profiles allow you to create shortcuts to your favorite commands. Some
profiles are created for you when you first run zoom. Use the
following command to list your profiles:

```bash
$ z -l
```

These profiles do not need to be limited to ag/ack/grep shortcuts.

Note: The `default` profile is special and can't be deleted. You can
however modify it.

## Penetration testing

zoom allows to you create profiles for commands other than
ag/ack/grep. This may make zoom a friendly tool for pen-testers who
are looking for a simple way to store exploits.

## TODO

 - Need to test to see if any ag/ack/grep flags break functionality.
 - Sometimes ag thinks files aren't binary when they should (?) be.
   For example, some pdfs are skipped b/c they are binary files, but
   some pdfs aren't skipped. Maybe file an issue on the ag Github
   page.
 - Make comments/documentation more thorough.
