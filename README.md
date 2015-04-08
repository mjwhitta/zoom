# Zoom

## Inspired by [sack](https://github.com/sampson-chen/sack)

### Quickly open CLI search results in your favorite editor!

Do you like to search through code using ag, ack, or grep? Good! This tool is for you! Zoom adds some convenience to ag/ack/grep by allowing you to quickly open your search results in your editor of choice. When looking at large code-bases, it can be a pain to have to scroll to find the filename of each result. Zoom prints a tag number in front of each result that ag/ack/grep outputs. Then you can quickly open that tag number with Zoom to jump straight to the source. Zoom is even persistent across all your sessions! You can search in one terminal and jump to a tag in another terminal from any directory!

## How to install

Open a terminal and run the following:

```bash
$ git clone https://gitlab.com/mjwhitta/zoom
$ cd zoom
$ ./install_zoom.sh
```

The default install directory is `~/bin`. You can change this by passing in the install directory of you choice like below:

```bash
$ ./install_zoom.sh ~/scripts
```

## Mac users

If using the grep operator, you need to install [homebrew](http://brew.sh) and then run the following commands before using Zoom:

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
    -e, --editor=EDITOR              Use the specified editor
    -f, --flags=FLAGS                Set flags for current profile
        --find                       Use the zoom_find profile
    -g, --go=NUM                     Open editor to search result NUM
    -h, --help                       Display this help message
    -l, --list                       List profiles
        --list-profile-names         List profile names for completion functions
        --list-tags                  List tags for completion functions
    -o, --operator=OPERATOR          Set operator for current profile
        --pager                      Treat Zoom as a pager (internal use only)
    -p, --prepend=PREPEND            Set the prepend string for the current profile
    -r, --repeat                     Repeat the last Zoom command
        --rc                         Create default .zoomrc file
        --rename=NAME                Rename the current profile
    -s, --switch=NAME                Switch to profile with specified name
    -u, --use=NAME                   Use specified profile one time only
    -w, --which                      Display the current profile

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
    $ z --prepend "cd /some/path;"

Execute the current profile:
    $ z PATTERN

Repeat the previous Zoom command:
    $ z --repeat

Pass additional flags to the choosen operator:
    $ z -- -A 3 PATTERN

Open a tag:
    $ z --go 10

Open multiple tags:
    $ z --go 10,20,30-40
```

You can use Zoom basically the same way you use ag/ack/grep.

## Shortcuts

Zoom prefixes shortcut tags to ag/ack/grep's search results! If you use Zoom to search for "find_in_path" in the Zoom source directory, you would see something like the following:

```bash
$ z find_in_path
zoom.rb
[1] 29:            op = find_in_path(operator)
[2] 33:                self["operator"] = find_in_path("grep")
[3] 61:    if (find_in_path("ag"))
[4] 75:    if (find_in_path("ack"))
[5] 77:    elsif (find_in_path("ack-grep"))
[6] 128:    editor = find_in_path(ENV["EDITOR"])
[7] 130:        editor = find_in_path("vim")
[8] 133:        editor = find_in_path("vi")
[9] 157:def find_in_path(cmd)
[10] 456:    if (find_in_path("ag"))
[11] 458:    elsif (find_in_path("ack"))
[12] 460:    elsif (find_in_path("ack-grep"))
[13] 487:    ed = find_in_path(options["editor"])
```

Now you can jump to result 9 with the following command:

```bash
$ z --go 9
```

### Persistent shortcuts

When you perform a search with Zoom, all results are cached. Using the following command will allow you to see the previous search results again:

```bash
$ z --cache
```

This means your tags/shortcuts are persistent across all sessions. You can use other terminals to view your search results or to open them in an editor.

## Profiles

Profiles allow you to create shortcuts to your favorite commands. Some profiles are created for you when you first run Zoom. Use the following command to list your profiles:

```bash
$ z --list
```

These profiles do not need to be limited to ag/ack/grep shortcuts.

Note: The `default` profile is special and can't be deleted. You can however modify it.

## Convenient symlinks

If you find it tedious to use Zoom with the flags, there are currently 4 convience symlinks that are supported.

- `zc` is the same as `z --cache` or `z -c`
- `zg` is the same as `z --go` or `z -g`
- `zl` is the same as `z --list` or `z -l`
- `zr` is the same as `z --repeat` or `z -r`

## Penetration testing

Zoom allows to you create profiles for commands other than ag/ack/grep. This may make Zoom a friendly tool for pen-testers who are looking for a simple way to store exploits.

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

If you don't know what grep is, this probably isn't the tool for you. You should learn how to properly use grep before using a tool such as Zoom which attempts to streamline the process for you.

## ZSH completion function

For some simple zsh completion with Zoom, you can add the following to
your `~/.zshrc`:

```bash
fpath=(/path/to/zoom/repo $fpath)
```

You may need to run the following command to update your completion
functions:

```bash
$ rm -f ~/.zcompdump; compinit
```

## TODO

 - Need to test to see if any ag/ack/grep flags break functionality.
 - Sometimes ag thinks files aren't binary when they should (?) be. For example, some pdfs are skipped b/c they are binary files, but some pdfs aren't skipped. Maybe file an issue on the ag Github page.
 - Make comments/documentation more thorough.
