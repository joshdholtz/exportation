# exportation
CLI tool of easy exporting, encrypting, and decrypting of certificates and private keys

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
