# zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### A faster way to use ag/ack/grep

Do you like to search through code using ag, ack, or grep? Good! This
tool is for you! zoom adds some convenience to ag/ack/grep by allowing
you to quickly open your search results in your editor of choice
(currently only vim and emacs are supported). When looking at large
code-bases, it can be a pain to have to scroll to find the filename of
each result. zoom prints a tag number in front of each result that
ag/ack/grep outputs. Then you can quickly open that tag number with
zoom to jump straight to the source. zoom is even persistent across
all your sessions! You can search in one terminal and jump to a tag in
another terminal from any directory!

## How to install

Open a terminal and run the following:

```bash
$ git clone https://bitbucket.org/mjwhitta/zoom
$ cd zoom
$ ./install_zoom.sh
```

## Mac users

If using the grep operator, you need to install
[homebrew](http://brew.sh) and then run the following commands before
using zoom:

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
    -f, --flags=FLAGS                Set flags for current profile
    -g, --go=NUM                     Open editor to search result NUM
    -h, --help                       Display this help message
    -l, --list                       List profiles
    -o, --operator=OPERATOR          Set operator for current profile
    -p, --prepend=PREPEND            Set the prepend string for the current profile
        --rc                         Create default .zoomrc file
    -r, --rename=NAME                Rename the current profile
    -s, --switch=NAME                Switch to profile with specified name
    -u, --use=NAME                   Use specified profile one time only
    -w, --which                      Display the current profile

zoom allows users to store commands/flags they use often into a profile. They can then use or modify that profile at any time.

EXAMPLES:

Add a profile named test:
    $ z --add test

Change the operator of the current profile:
    $ z --operator grep

Change the operator of the profile "test":
    $ z --use test --operator grep

Change the flags of the current profile:
    $ z --flags "--color=always -EHIinR"

Change the prepend string of the current profile:
    $ z --prepend "PATH=/bin"

Execute the current profile:
    $ z PATTERN

Pass additional flags to the choosen operator:
    $ z -- -A 3 PATTERN
```

You can use zoom basically the same way you use ag/ack/grep.

## Shortcuts

zoom prefixes shortcut tags to ag/ack/grep's search results like
below:

```bash
$ z def
zoom.rb
[TAG] 8:    def flags(flags = nil)
[TAG] 15:    def info()
[TAG] 21:    def initialize(operator, flags = "", env_prepend = "")
[TAG] 27:    def operator(operator = nil)
[TAG] 39:    def prepend(env_prepend = nil)
[TAG] 46:    def to_s()
[TAG] 55:def default_zoomrc()
[TAG] 59:    # Default ag profiles
[TAG] 72:    # Default ack profile
[TAG] 89:    # Default grep profile (emulate ag/ack as much as possible)
[TAG] 98:        default = ag
[TAG] 100:        default = ack
[TAG] 102:        default = grep
[TAG] 106:    profs["default"] = default
[TAG] 116:    # Default editor
[TAG] 122:    rc["profile"] = "default"
[TAG] 128:def exe_command(profile, pattern)
[TAG] 147:def find_in_path(cmd)
[TAG] 163:def is_exe?(cmd)
[TAG] 168:def open_editor_to_result(editor, result)
[TAG] 173:def parse(args)
[TAG] 232:        opts.on("--rc", "Create default .zoomrc file") do
[TAG] 233:            default_zoomrc
[TAG] 261:def read_zoomrc()
[TAG] 263:        default_zoomrc
[TAG] 278:def remove_colors(str)
[TAG] 282:def shortcut_cache()
[TAG] 326:def write_zoomrc(rc)
[TAG] 385:        rc["profile"] = "default"
[TAG] 388:    if (prof != "default")
[TAG] 392:        puts "You can't delete the default profile!"
```

Now you can jump to a specific search result by typing:

```bash
$ z --go TAG
```

This will cause zoom to open the search result in vim/emacs (currently
the only supported editors)

### Persistent shortcuts

When you perform a search with zoom, all results are cached. Using the
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
profiles are created for you when you first run zoom. Use the
following command to list your profiles:

```bash
$ z --list
```

These profiles do not need to be limited to ag/ack/grep shortcuts.

Note: The `default` profile is special and can't be deleted. You can
however modify it.

## Penetration testing

zoom allows to you create profiles for commands other than
ag/ack/grep. This may make zoom a friendly tool for pen-testers who
are looking for a simple way to store exploits.

## What is [ag](https://github.com/ggreer/the_silver_searcher)?

ag is a faster version of ack!

## What is [ack](http://betterthangrep.com)?

ack is the replacement for grep!

## What is [grep](http://en.wikipedia.org/wiki/Grep)?

If you don't know what grep is, this probably isn't the tool for you.
You should learn how to properly use grep before using a tool such as
zoom which attempts to streamline the process for you.

## TODO

 - Need to test to see if any ag/ack/grep flags break functionality.
 - Sometimes ag thinks files aren't binary when they should (?) be.
   For example, some pdfs are skipped b/c they are binary files, but
   some pdfs aren't skipped. Maybe file an issue on the ag Github
   page.
 - Make comments/documentation more thorough.
