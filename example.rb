require './lib/exportation'

keychain = Exportation::Keychain.find_or_create_keychain('JoshChain', 'joshiscool', './example')
puts "Keychain - #{keychain}"

keychain.import_certificate './example/dist.cer'
keychain.import_private_key './example/dist.p12', ''

keychain.unlock!

keychain.add_to_keychain_list!

# Do some iOS building stuff here

keychain.remove_keychain_from_list!
