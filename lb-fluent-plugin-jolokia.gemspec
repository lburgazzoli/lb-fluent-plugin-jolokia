# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-jolokia"
  gem.description = "Jolokia plugin for Fluent event collector"
  gem.homepage    = "https://github.com/lburgazzoli/lb-fluent-plugin-jolokia"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Luca Burgazzoli"]
  gem.email       = "nomail@gmail.com"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency             "fluentd"   , ">= 0.10.33"
  gem.add_dependency             "httparty"  , ">= 0.11.0"
  gem.add_development_dependency "rake"      , ">= 10.0.4"
  gem.add_development_dependency "simplecov" , ">= 0.7.1"
  gem.add_development_dependency "rr"        , ">= 1.1.0"
end

