Gem::Specification.new do |s|
  s.name        = "nested_form"
  s.version     = "0.3.2"
  s.authors     = ["Ryan Bates", "Andrea Singh"]
  s.email       = "ryan@railscasts.com"
  s.homepage    = "http://github.com/ryanb/nested_form"
  s.summary     = "Gem to conveniently handle multiple models in a single form."
  s.description = "Gem to conveniently handle multiple models in a single form with Rails 4 and jQuery or Prototype. 
                   Added support for serialized JSON"

  s.files        = Dir["{lib,spec,vendor}/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "mocha"
  s.add_development_dependency "capybara"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "launchy"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
