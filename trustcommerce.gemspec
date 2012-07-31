# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "trustcommerce/version"

Gem::Specification.new do |s|
  s.name        = "trustcommerce"
  s.version     = Trustcommerce::VERSION
  s.authors     = ["zackchandler@depixelate.com"]
  s.email       = ["brian@hwrd.com"]
  s.homepage    = 'http://trustcommerce.rubyforge.org'
  s.summary     = 'TrustCommerce Subscription Library'
  s.description = s.summary

  s.rubyforge_project = "trustcommerce"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "faraday"
  # s.add_runtime_dependency "rest-client"
end
