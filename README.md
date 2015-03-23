# exportation
[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@joshdholtz-blue.svg?style=flat)](https://twitter.com/joshdholtz)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/joshdholtz/exportation/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/exportation.svg?style=flat)](http://rubygems.org/gems/exportation)
[![Build Status](https://img.shields.io/travis/joshdholtz/exportation/master.svg?style=flat)](https://travis-ci.org/joshdholtz/exportation)

CLI tool (and Ruby API) of easy exporting, encrypting, and decrypting of certificates and private keys. It can also add certificates and private keys to an existing or new keychain :grinning:

**Important:** The `export` command will take control of your "Keychain Access" app so keep all hands off your computer while that command runs

### Example usage (with prompt)
```sh
$: exportation export
Name: RokkinCat LLC
Path to save to (default: './'): ./examples
Filename to save as (default: 'export'): dist
Password for private key (default: ''): shhh
Info  Take all hands off your computer! exportation is going to take control of 'Keychain Access'
```

![Example of exportation](readme_assets/example.gif)

### Why
- Export **and** encrypt certificates **and** private keys **into** repos
  - CI tools (may need these to distrubute builds to Apple TestFlight Beta :apple:)
  - For other developers (for when you are on vacation and they need to make a distribution build :grimacing:)

### How
- Makes use of AppleScript to control "Keychain Access"
  - Opens "Keychain Access"
  - Selects "Login" and "Certificates" for the left side
  - Searches for the certificate you are looking for from `--name`
  - Exports private key
    - Right clicks it and selects export
    - Changes the save path to your current directory (by default) or what was passed in through `--path`
    - Saves the file to `exported.p12`
    - Enters a blank password (by default) or what was passed in through `--password`
    - Saves
  - Exports certificate
    - Right clicks it and selects export
    - Changes the save path to your current directory (by default) or what was passed in through `--path`
    - Saves the file to `exported.cer`
    - Saves

### Features in progress
- Integrate with [fastlane](https://github.com/KrauseFx/fastlane) :rocket:

### Caveats
- Some phases of the script might run slow due to using AppleScript
  - Initial load may take up to 5ish seconds
  - Waiting for private key password to be entered may take up to 7ish seconds
- May need to give "Accessibility" access to **ARDAgent** and **Terminal**

## Installation

### Install gem
```sh
gem install exportation
```

### Give "Accessibility" access
- Open up "Security & Privacy" preferences
- Select "Accessibility"
- Add **ARDAgent** and **Terminal**
  - Click "+"
  - Press CMD+SHIT+G (to go to specific folder)
  - **ARDAgent** should be under `/System/Library/CoreServices/RemoteManagement/`
  - **Terminal** should be under `/Applications/Utilities/`

![](readme_assets/access.png)
**You won't need to give Heroes, Script Editor, or Steam permissions for exportation** :wink:

## CLI Commands
Exportation has three different commands: `export`, `encrypt`, and `decrypt`.

### Export from Keychain Access
**Be lazy!** `export` uses AppleScript to control the "Keychain Access" app to export a certificate and private to be used for CI (continuous integration) or for other developers.
```sh
exportation export --name "Your Company LLC"
```

### Encrypting certificate and private key
**Be safe!** `encrypt` does exactly what it says - it encrypts. It uses AES-256 to encrypt your certificate, private keys and provisioning profiles (any file really) to store safely in your repository for CIs or other developers to access. All files will be appened with a `.enc` extension.
```sh
exportation encrypt exported.cer exported.p12 --password dudethis
```

### Decrypting certificate and private key
**Be awesome!** `decrypt` decrypts your encrypted files to use on your CI or for other developers to install. *BE CAREFULL TO NOT COMMIT THESE BACK INTO YOUR REPO*
```sh
exportation decrypt exported.cer.enc exported.p12.enc --password dudethis
```

## Ruby API

### Exportation::Export
```ruby
Exportation::Export.new(
  path: "/path/to/export/to",
  filename: "base_exported_file_name", #dist.cer and dist.p12
  name: "YourCompany LLC",
  password: "shhhh"
).run
```

### Exportation::Crypter

#### Encrypt
```ruby
Exportation::Crypter.new(
  files: ["dist.cer","dist.p12"],
  password: "shhhh",
  output: "./"
).run :en
```

#### Decrypt
```ruby
Exportation::Crypter.new(
  files: ["dist.cer.enc","dist.p12.enc"],
  password: "shhhh",
  output: "./"
).run :de
```

### Exportation::Keychain
```ruby
# Create keychain - name of chain, password, output directory
keychain = Exportation::Keychain.find_or_create_keychain('JoshChain', 'joshiscool', './example')

# Get login keychain
keychain = Exportation::Keychain.login_keychain("password")

# Import a certificate into keychain
keychain.import_certificate './example/dist.cer'

# Import a private key into keychain
keychain.import_private_key './example/dist.p12', 'da_password'

# Unlock keychain
keychain.unlock!

# Adds keychain to search list
keychain.add_to_keychain_list!

# Removes keychain from search list
keychain.remove_keychain_from_list!
```

## Fastlane integration

```ruby
lane :ci_build do

  enc_password = ENV['ENC_PASSWORD']
  keychain_password = ENV['KEYCHAIN_PASSWORD']
  private_key_password = ENV['PKEY_PASSWORD']

  # Cleaning house and making directories
  sh "rm -rf ../build"
  sh "mkdir ../build"
  sh "mkdir ../build/unenc"

  # Decrypting cert and private key
  Exportation::Crypter.new(
    files: ["../circle/dist.cer.enc", "../circle/dist.p12.enc"],
    password: enc_password,
    output: "../build/unenc/"
  ).run :de

  # Creating keychain to use for xcodebuild
  keychain = Exportation::Keychain.find_or_create_keychain 'ios-build', keychain_password, '../build'

  # Importing the Apple certificate and the uncrypted cert and private key
  keychain.import_certificate '../circle/apple.cer'
  keychain.import_certificate '../build/unenc/dist.cer'
  keychain.import_private_key '../build/unenc/dist.p12', private_key_password

  # Unlocking keychain (defaults to 1 hour) and adds keychain to user search list
  keychain.unlock!
  keychain.add_to_keychain_list!

  # Building archive
  xcodebuild(
    clean: true,
    archive: true,
    archive_path: './build/YourApp.xcarchive',
    workspace: ENV['WORKSPACE'],
    scheme: ENV['SCHEME'],
    configuration: 'Release',
    sdk: 'iphoneos',
    keychain: keychain.path
    )

  # Building IPA
  xcodebuild(
    export_archive: true,
    export_path: './build/YourApp'
    )

  # Send to HockeyApp
  hockey({
    api_token: ENV['HOCKEYAPP_API_TOKEN'],
    ipa: Actions.lane_context[ Actions::SharedValues::IPA_OUTPUT_PATH ],
    notify: 1
  })

  # Cleaning house again
  sh "rm -rf ../circle/unenc"
  keychain.remove_keychain_from_list!

end
```

## Using the internals

### Compiling and running the AppleScript directly
*You shouldn't ever have to do this unless I messed stuff up :)*

### Compile
```sh
osacompile -o applescript/exportation.scpt applescript/exportation.applescript
```

### Run
Always put all for arguments in strings because I don't do AppleScript well :grimacing:
```sh
osascript applescript/exportation.scpt "~/directory_you_want_to_export_to/" "dist" "iPhone Distribution: Your Company LLC"  "thepassword"
```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

exportation is available under the MIT license. See the LICENSE file for more info.
