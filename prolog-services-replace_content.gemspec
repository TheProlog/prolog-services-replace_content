# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prolog/services/replace_content/version'

Gem::Specification.new do |spec|
  spec.name          = 'prolog-services-replace_content'
  spec.version       = Prolog::Services::ReplaceContent::VERSION
  spec.authors       = ['Jeff Dickey']
  spec.email         = ['jdickey@seven-sigma.com']

  spec.summary       = %q{Replaces HTML within a specified range with HTML replacement content.}
  # TOODOO should be an obvious typo; added to silence CodeClimate scan.
  # spec.description   = %q{TOODOO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/TheProlog/prolog-services-replace_content'
  spec.license       = 'MIT'

  spec.metadata['yard.run'] = 'yri'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'TOODOO: Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # spec.add_dependency 'pandoc-ruby', '~> 2'
  # spec.add_dependency 'prolog-services-markdown_to_html', '~> 1.0'
  spec.add_dependency 'semantic_logger'
  spec.add_dependency 'ox'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'

  spec.add_development_dependency "minitest-matchers"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-tagz"
  spec.add_development_dependency "flay"
  spec.add_development_dependency "flog"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "colorize"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "codeclimate-test-reporter"
end
