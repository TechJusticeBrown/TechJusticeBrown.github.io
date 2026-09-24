# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-nagymaros"
  spec.version       = "3.4.0"
  spec.authors       = ["piazzai"]
  spec.email         = ["hello@piazzai.addy.io"]

  spec.summary       = "Jekyll theme for a conference website"
  spec.homepage      = "https://github.com/piazzai/jekyll-nagymaros"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_data|_layouts|_includes|_sass|LICENSE|README|_config\.yml)!i) }

  spec.add_runtime_dependency "github-pages", "~> 232"
end
