require 'bundler'
Bundler::GemHelper.install_tasks

#Added to get testing working
require 'rake/testtask'
Rake::TestTask.new(:test)

require "rake/rdoctask"
Rake::RDocTask.new do |rd| 
 rd.rdoc_files.include("lib/**/*.rb")
 rd.rdoc_dir = "rdoc"
end
