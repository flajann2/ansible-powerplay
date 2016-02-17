# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: ansible-powerplay 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "ansible-powerplay"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Fred Mitchell"]
  s.date = "2016-02-17"
  s.description = "Ansible Powerplay, by way of its DSL, allows you to\n                       specify your Ansible playbooks and their vars, and common\n                       vars to all, so that you can run your\n                       indeoendent playbooks in full parallel."
  s.email = "fred.mitchell@gmx.de"
  s.executables = ["powerplay"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.org"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".ruby-version",
    ".semver",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.org",
    "Rakefile",
    "SCRATCHPAD.org",
    "ansible-powerplay.gemspec",
    "bin/powerplay",
    "lib/ansible-powerplay.rb",
    "lib/ansible-powerplay/cli.rb",
    "lib/ansible-powerplay/dsl.rb",
    "lib/ansible-powerplay/powerplay.rb",
    "spec/ansible-powerplay_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/flajann2/ansible-powerplay"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0")
  s.rubygems_version = "2.5.1"
  s.summary = "Powerplay enables you to run Ansible playbooks in parallel."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, ["~> 0"])
      s.add_runtime_dependency(%q<concurrent-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2"])
      s.add_development_dependency(%q<yard>, ["~> 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3"])
      s.add_development_dependency(%q<bundler>, ["~> 1"])
      s.add_development_dependency(%q<juwelier>, ["~> 2"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<semver>, ["~> 1"])
      s.add_development_dependency(%q<guard>, ["~> 2"])
      s.add_development_dependency(%q<guard-rspec>, ["~> 1"])
      s.add_development_dependency(%q<pry>, ["~> 0"])
      s.add_development_dependency(%q<pry-byebug>, ["~> 3"])
      s.add_development_dependency(%q<pry-doc>, ["~> 0"])
      s.add_development_dependency(%q<pry-remote>, ["~> 0"])
      s.add_development_dependency(%q<pry-rescue>, ["~> 1"])
      s.add_development_dependency(%q<pry-stack_explorer>, ["~> 0"])
    else
      s.add_dependency(%q<thor>, ["~> 0"])
      s.add_dependency(%q<concurrent-ruby>, [">= 0"])
      s.add_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2"])
      s.add_dependency(%q<yard>, ["~> 0"])
      s.add_dependency(%q<rdoc>, ["~> 3"])
      s.add_dependency(%q<bundler>, ["~> 1"])
      s.add_dependency(%q<juwelier>, ["~> 2"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<semver>, ["~> 1"])
      s.add_dependency(%q<guard>, ["~> 2"])
      s.add_dependency(%q<guard-rspec>, ["~> 1"])
      s.add_dependency(%q<pry>, ["~> 0"])
      s.add_dependency(%q<pry-byebug>, ["~> 3"])
      s.add_dependency(%q<pry-doc>, ["~> 0"])
      s.add_dependency(%q<pry-remote>, ["~> 0"])
      s.add_dependency(%q<pry-rescue>, ["~> 1"])
      s.add_dependency(%q<pry-stack_explorer>, ["~> 0"])
    end
  else
    s.add_dependency(%q<thor>, ["~> 0"])
    s.add_dependency(%q<concurrent-ruby>, [">= 0"])
    s.add_dependency(%q<term-ansicolor>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2"])
    s.add_dependency(%q<yard>, ["~> 0"])
    s.add_dependency(%q<rdoc>, ["~> 3"])
    s.add_dependency(%q<bundler>, ["~> 1"])
    s.add_dependency(%q<juwelier>, ["~> 2"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<semver>, ["~> 1"])
    s.add_dependency(%q<guard>, ["~> 2"])
    s.add_dependency(%q<guard-rspec>, ["~> 1"])
    s.add_dependency(%q<pry>, ["~> 0"])
    s.add_dependency(%q<pry-byebug>, ["~> 3"])
    s.add_dependency(%q<pry-doc>, ["~> 0"])
    s.add_dependency(%q<pry-remote>, ["~> 0"])
    s.add_dependency(%q<pry-rescue>, ["~> 1"])
    s.add_dependency(%q<pry-stack_explorer>, ["~> 0"])
  end
end

