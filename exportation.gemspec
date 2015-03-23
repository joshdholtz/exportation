Gem::Specification.new do |s|
  s.name        = 'exportation'
  s.version     = '0.2.2'
  s.date        = '2015-03-21'
  s.summary     = "CLI tool of easy exporting, encrypting, and decrypting of certificates and private keys"
  s.description = "CLI tool of easy exporting, encrypting, and decrypting of certificates and private keys using Keychain Acess and openssl"
  s.authors     = ["Josh Holtz"]
  s.email       = 'me@joshholtz.com'
  s.homepage    =
    'https://github.com/joshdholtz/exportation'
  s.license       = 'MIT'

  s.files       = Dir["lib/**/*"] + %w{ bin/exportation README.md LICENSE applescript/exportation.scpt }
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'dotenv', '~> 0.7'
  s.add_dependency 'commander', '~> 4.3'
  s.add_dependency 'colorize', '~> 0.7'
  s.add_dependency 'terminal-notifier', '~> 1.6'

  s.add_development_dependency "rspec"
end
