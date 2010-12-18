# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "verbvector/version"

Gem::Specification.new do |s|
  s.name        = "verbvector"
  s.version     = Lingustics::Verbs::Verbvector::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steven G. Harms"]
  s.email       = ["github@sgharms.oib.com"]
  s.homepage    = "http://rubygems.org/gems/verbvector"
  s.summary     = %q{Generates the verb tense "vectors" based on a DSL description syntax.}
  s.description = %q{Use a DSL to describe the verb tense framework of a language and have it generate methods corresponding to each unique vector.}

  s.rubyforge_project = "verbvector"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
