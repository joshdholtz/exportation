# exportation
CLI tool of easy exporting, encrypting, and decrypting of certificates and private keys.

### Features in progress
- Integrate with [fastlane](https://github.com/KrauseFx/fastlane) :rocket:
- Create a separate keychain with the certificates and private keys for use on CI systems :grinning:

## Commands
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
