$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "will_paginate-liquidized"
  s.version     = "1.0.0"
  s.authors     = ["Jose Antonio Silva Portell"]
  s.email       = ["jsilva@modyo.com"]
  s.homepage    = "http://www.modyo.com"
  s.summary     = "WillPaginate for Liquid templates"
  s.description = "WillPaginate for Liquid Templates"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.9"
  s.add_dependency "liquid"

end
