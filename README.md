# zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### A faster way to use ag/ack/grep

zoom acts as a wrapper for ag/ack/grep or any command really. The goal
was to provide convenience when searching through codebases via the
cli.

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
[1] 8:    def flags(flags = nil)
[2] 15:    def info()
[3] 21:    def initialize(operator, flags = "", env_prepend = "")
[4] 27:    def operator(operator = nil)
[5] 39:    def prepend(env_prepend = nil)
[6] 46:    def to_s()
[7] 55:def default_zoomrc()
[8] 59:    # Default ag profiles
[9] 72:    # Default ack profile
[10] 89:    # Default grep profile (emulate ag/ack as much as possible)
[11] 98:        default = ag
[12] 100:        default = ack
[13] 102:        default = grep
[14] 106:    profs["default"] = default
[15] 116:    # Default editor
[16] 122:    rc["profile"] = "default"
[17] 128:def exe_command(profile, pattern)
[18] 147:def find_in_path(cmd)
[19] 163:def is_exe?(cmd)
[20] 168:def open_editor_to_result(editor, result)
[21] 173:def parse(args)
[22] 232:        opts.on("--rc", "Create default .zoomrc file") do
[23] 233:            default_zoomrc
[24] 261:def read_zoomrc()
[25] 263:        default_zoomrc
[26] 278:def remove_colors(str)
[27] 282:def shortcut_cache()
[28] 326:def write_zoomrc(rc)
[29] 385:        rc["profile"] = "default"
[30] 388:    if (prof != "default")
[31] 392:        puts "You can't delete the default profile!"
```

Now you can jump to a search result by typing:

```bash
$ z -g NUM
```

This will cause zoom to open the search result in vim (currently the
only supported editor)

### Cross-Terminal Shortcuts

When you perform a search with zoom, all results are cached. Using the
following command will allow you to see the previous search's results
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

## Pentesting

zoom allows to you create profiles for commands other than
ag/ack/grep. This may make zoom a friendly tool for pentesters who are
looking for a simple way to store exploits.
