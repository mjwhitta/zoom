require "fileutils"
require "io/wait"
require "scoobydoo"

class Zoom::Editor
    def default(results)
        # First result should never be nil, but better safe than sorry
        first_result = results.delete_at(0)
        open_result(first_result) if (first_result)

        results.each do |result|
            print "Open result #{result.tag} [y]/n/q/l?: "
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
                open_result(result)
                break
            when "q", "Q", "\x03"
                # Quit or ^C
                break
            else
                open_result(result)
            end
        end
    end
    private :default

    def initialize(editor)
        @editor, _, @flags = editor.partition(" ") if (editor)
        if (editor.nil?)
            @editor = ENV["EDITOR"] || "vim"
            @editor= "vi" if (ScoobyDoo.where_are_you(@editor).nil?)
            @flags = ""
        end
    end

    def open(results)
        return if (results.nil? || results.empty?)

        case @editor
        when /vim?$/
            vim(results)
        else
            default(results)
        end
    end

    def open_result(result)
        if (result.grep_like?)
            if (result.filename.start_with?("/"))
                filename = result.filename
            else
                filename = result.pwd + "/" + result.filename
            end
            lineno = result.lineno
            system("#{@editor} #{@flags} +#{lineno} '#{filename}'")
        else
            if (result.contents.start_with?("/"))
                filename = result.contents
            else
                filename = result.pwd + "/" + result.contents
            end
            system("#{@editor} #{@flags} '#{filename}'")
        end
    end
    private :open_result

    def vim(results)
        quickfix = Pathname.new("~/.cache/zoom/quickfix").expand_path
        source = Pathname.new("~/.cache/zoom/source").expand_path
        FileUtils.mkdir_p(quickfix.dirname)

        zq = File.open(quickfix, "w")
        zs = File.open(source, "w")

        vimscript = [
            "augroup Zoom",
            "  autocmd!",
            "  autocmd FileType qf nnoremap <cr> :.cc<cr>:cclose<cr>",
            "augroup END",
            "",
            "nnoremap <leader>z :copen<cr>",
            "nnoremap zn :cn<cr>",
            "nnoremap zp :cp<cr>",
            ""
        ].join("\n")
        zs.write(vimscript)

        files = Array.new
        results.each do |result|
            if (result.grep_like?)
                if (result.filename.start_with?("/"))
                    filename = result.filename
                else
                    filename = result.pwd + "/" + result.filename
                end
            else
                if (result.contents.start_with?("/"))
                    filename = result.contents
                else
                    filename = result.pwd + "/" + result.contents
                end
            end

            lineno = result.lineno
            match = result.match

            if (!files.include?(filename))
                files.push(filename)
                zs.write("#{lineno}\nbnext\n") if (result.grep_like?)
            end

            if (result.grep_like?)
                zq.write("#{filename}:#{lineno}: #{match}\n")
            end
        end
        zs.write("silent cfile #{quickfix}\n")

        zq.close
        zs.close

        system(
            "#{@editor} #{@flags} -S #{source} '#{files.join("' '")}'"
        )

        FileUtils.rm_f(quickfix)
        FileUtils.rm_f(source)
    end
end
