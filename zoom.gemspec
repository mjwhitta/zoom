Gem::Specification.new do |s|
    s.name = "ruby-zoom"
    s.version = "3.0.0"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary =
        "Quickly open CLI search results in your favorite editor!"
    s.description =
        "Do you like to search through code using ag, ack, or " \
        "grep? Good! This tool is for you! Zoom adds some " \
        "convenience to ag/ack/grep by allowing you to quickly " \
        "open your search results in your editor of choice. When " \
        "looking at large code-bases, it can be a pain to have to " \
        "scroll to find the filename of each result. Zoom prints a " \
        "tag number in front of each result that ag/ack/grep " \
        "outputs. Then you can quickly open that tag number with " \
        "Zoom to jump straight to the source. Zoom is even " \
        "persistent across all your sessions! You can search in " \
        "one terminal and jump to a tag in another terminal from " \
        "any directory!"
    s.authors = [ "Miles Whittaker" ]
    s.email = "mjwhitta@gmail.com"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/*.rb"]
    s.homepage = "http://mjwhitta.github.io/zoom"
    s.license = "GPL-3.0"
    s.add_development_dependency("minitest", "~> 5.8", ">= 5.8.1")
    s.add_runtime_dependency("scoobydoo", "~> 0.1", ">= 0.1.1")
end
