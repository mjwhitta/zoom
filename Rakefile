require "fileutils"
require "rake/testtask"

aliases = ["zc", "zf", "zg", "zl", "zr"].map do |aliaz|
    "bin/#{aliaz}"
end

task :default => :gem

desc "Clean up"
task :clean do
    system("rm -f *.gem Gemfile.lock #{aliases.join(" ")}")
    system("chmod -R go-rwx bin lib")
end

desc "Build gem"
task :gem do
    aliases.each do |aliaz|
        FileUtils.cp("bin/z", aliaz)
    end
    system("chmod -R u=rwX,go=rX bin lib")
    system("gem build -V *.gemspec")
end

desc "Build and install gem"
task :install => :gem do
    system("gem install *.gem")
end

desc "Push gem to rubygems.org"
task :push => [:clean, :gem] do
    system("gem push *.gem")
end

desc "Run tests"
Rake::TestTask.new do |t|
    t.libs << "test"
end
