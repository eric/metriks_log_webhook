require 'rubygems'
require 'rake'
require 'date'

#############################################################################
#
# Standard tasks
#
#############################################################################

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

# desc "Generate RCov test coverage and open in your browser"
# task :coverage do
#   require 'rcov'
#   sh "rm -fr coverage"
#   sh "rcov test/*_test.rb"
#   sh "open coverage/index.html"
# end
# 
# require 'rake/rdoctask'
# Rake::RDocTask.new do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = "#{name} #{version}"
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
# 
# desc "Open an irb session preloaded with this library"
# task :console do
#   sh "irb -rubygems -r ./lib/#{name}.rb"
# end