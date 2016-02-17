# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'semver'

def s_version
  SemVer.find.format "%M.%m.%p%s"
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "ansible-powerplay"
  gem.homepage = "http://github.com/flajann2/ansible-powerplay"
  gem.license = "MIT"
  gem.summary = %Q{Powerplay enables you to run Ansible playbooks in parallel. }
  gem.description = %Q{Ansible Powerplay, by way of its DSL, allows you to
                       specify your Ansible playbooks and their vars, and common
                       vars to all, so that you can run your
                       indeoendent playbooks in full parallel.}
  gem.email = "fred.mitchell@gmx.de"
  gem.authors = ["Fred Mitchell"]
  gem.version = s_version
  gem.required_ruby_version = '>= 2.0'

  # Exclusions
  gem.files.exclude 'foo/**/*', 'rdoc/*', 'examples/*', '*.log',
                    '.idea/**/*', '.idea/**/.*', '.yardoc/**/*',
                    'Guardfile'
end
Juwelier::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
