# exportation
CLI tool of easy exporting, encrypting, and decrypting of certificates and private keys.

It also can put the certificate and private key in a separate keychain for you :grinning:

### Running

#### Export from Keychain Access
```sh
exportation export --name "Your Company LLC"
```

#### Encrypting certificate and private key
```sh
exportation encrypt exported.cer exported.p12 --password dudethis
```

#### Decrypting certificate and private key
```sh
exportation decrypt exported.cer.enc exported.p12.enc --password dudethis
```

### Compiling and running the AppleScript directly
*You shouldn't ever have to do this unless I messed stuff up :)*

#### Compile
```sh
osacompile -o applescript/exportation.scpt applescript/exportation.applescript
```

#### Run
```sh
osascript applescript/exportation.scpt "~/directory_you_want_to_export_to/" "dist" "iPhone Distribution: Your Company LLC"  "thepassword"
```
