Gem::Specification.new do |s|
    s.name = "ruby-zoom"
    s.version = "4.3.0"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary =
        "Quickly open CLI search results in your favorite editor!"
    s.description = [
        "Do you like to search through code using ag, ack, grep, or",
        "pt? Good! This tool is for you! Zoom adds some convenience",
        "to ag/ack/grep/pt by allowing you to quickly open your",
        "search results in your editor of choice. When looking at",
        "large code-bases, it can be a pain to have to scroll to",
        "find the filename of each result. Zoom prints a tag number",
        "in front of each result that ag/ack/grep/pt outputs. Then",
        "you can quickly open that tag number with Zoom to jump",
        "straight to the source. Zoom is even persistent across all",
        "your sessions! You can search in one terminal and jump to a",
        "tag in another terminal from any directory!"
    ].join(" ")
    s.authors = [ "Miles Whittaker" ]
    s.email = "mjwhitta@gmail.com"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://mjwhitta.github.io/zoom"
    s.license = "GPL-3.0"
    s.add_development_dependency("minitest", "~> 5.8", ">= 5.8.4")
    s.add_development_dependency("rake", "~> 10.5", ">= 10.5.0")
    s.add_runtime_dependency("djinni", "~> 2.0", ">= 2.0.1")
    s.add_runtime_dependency("hilighter", "~> 0.1", ">= 0.1.3")
    s.add_runtime_dependency("json_config", "~> 0.1", ">= 0.1.2")
    s.add_runtime_dependency("scoobydoo", "~> 0.1", ">= 0.1.4")
end
