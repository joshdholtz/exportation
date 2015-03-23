module Exportation

  def self.gem_path
    if Gem::Specification::find_all_by_name('exportation').any?
      return Gem::Specification.find_by_name('exportation').gem_dir
    else
      return './'
    end
  end

  def self.applescript_path
    File.join(gem_path, 'applescript', 'exportation.scpt')
  end

  def self.is_empty?(str)
    str.nil? || str.length == 0
  end

  class Export

    attr_accessor :path, :filename, :name, :password

    def initialize(options)
      @path = options[:path]
      @filename = options[:filename]
      @name = options[:name]
      @password = options[:password]

      @path = './' if Exportation.is_empty?(@path)
      @filename = 'exported' if Exportation.is_empty?(@filename)
      @password = '' if Exportation.is_empty?(@password)
    end

    def run
      bash = run_command
      puts "Running: #{bash}"
      `#{bash}`
    end

    def run_command
      raise "name is required" if Exportation.is_empty?(@name)

      abs_path = File.expand_path path
      abs_path += '/' unless abs_path.end_with? '/'

      bash = "osascript #{Exportation.applescript_path} " +
        "\"#{abs_path}\" " +
        "\"#{filename}\" " +
        "\"#{name}\" " +
        "\"#{password}\""
    end

  end

  class Crypter

    attr_accessor :files, :password, :output

    def initialize(options)
      @files = options[:files]
      @password = options[:password]
      @output = options[:output]
    end

    def run(crypt, force = false)
      run_commands(crypt, force).each do |bash|
        puts "Running: #{bash}"
        `#{bash}`
      end
    end

    def run_commands(crypt, force = false)
      raise "password is required" if Exportation.is_empty?(@password)

      unless force
        if crypt == :en
          # Verify files are not already encrypted
          files.each do |file|
            raise 'Some of these files may be encrypted (ending with .enc)' if file.end_with? '.enc'
          end
        elsif crypt == :de
          # Verify files are not already decrypted
          files.each do |file|
            raise 'Some of these files may be encrypted (ending with .enc)' unless file.end_with? '.enc'
          end
        end
      end

      # Does the stuff
      commands = []
      files.each do |file|
        file = './' + file unless file.start_with? '/'
        if File.exists? file
          output_file = file
          if !output.nil? && output.length > 0
            output_file = File.join(output, File.basename(file))
          end

          if crypt == :en
            output_file += '.enc'
          elsif crypt == :de
            output_file = output_file.gsub('.enc','')
          end

          commands << "openssl aes-256-cbc -k \"#{password}\" -in #{file} -out #{output_file} -a"
        else
          raise "File does not exist - #{file}"
        end
      end

      commands
    end

  end

  class Keychain

    attr_accessor :path, :password

    def initialize(options)
      @path = options[:path]
      @password = options[:password]
    end

    def self.find_or_create_keychain(name, password, output_directory='./')
      path = chain_path(name, output_directory)

      unless File.exists? path
        `security create-keychain -p '#{password}' #{path}`
      end

      Keychain.new(path: path, password: password)
    end

    def self.login_keychain(password)
      path = `security login-keychain`.strip
      Keychain.new(path: path, password: password)
    end

    def self.list_keychains
      # Gets a list of all the user's keychains in an array
      # The keychain are paths wrapped in double quotes
      (`security list-keychains -d user`).scan(/(?:\w|"[^"]*")+/)
    end

    def import_certificate(cer_path)
      # Imports a certificate into the keychain
      `security import #{cer_path} -k #{@path} -T /usr/bin/codesign`
    end

    def import_private_key(key_path, password)
      # Imports a private key into the keychain
      `security import #{key_path} -k #{@path} -P '#{password}' -T /usr/bin/codesign`
    end

    def unlock!(seconds=3600)
      # Unlocks the keychain
      `security unlock-keychain -p '#{@password}' #{@path}`
      `security -v set-keychain-settings -t #{seconds} -l #{@path}`
    end

    def add_to_keychain_list!
      # Adds the keychain to the search list
      keychains = (Keychain.list_keychains - ["\"#{@path}\""]).join(' ')
      `security list-keychains -d user -s #{keychains} \"#{@path}\"`
    end

    def remove_keychain_from_list!
      # Removes the keychain from the search list
      keychains = (Keychain.list_keychains - ["\"#{@path}\""]).join(' ')
      `security list-keychains -d user -s #{keychains}`
    end

    private

    def self.chain_path(name, output_directory='./')
      output_directory = File.expand_path output_directory
      File.join(output_directory, "#{name}.keychain")
    end

    # Creates keychain with cert and private key (this is how Xcode knows how to sign things)
    # sh "security create-keychain -p '#{keychain_password}' #{chain_path}"
    # sh "security import ./Certs/apple.cer -k #{chain_path} -T /usr/bin/codesign"
    # sh "security import ../build/unenc/dist.cer -k #{chain_path} -T /usr/bin/codesign"
    # sh "security import ../build/unenc/dist.p12 -k #{chain_path} -P '#{private_key_password}' -T /usr/bin/codesign"

    # sh "security unlock-keychain -p '#{keychain_password}' #{chain_path}"
    # sh "security -v set-keychain-settings -t 3600 -l #{chain_path}"
    #
    # # Add keychain to list (this is literally the key to getting this all working)
    # sh "security list-keychains -d user -s #{ENV['ORIGINAL_KEYCHAINS']} \"#{chain_path}\""

    # Reset keychains to what was originally set for user
    # sh "security list-keychains -d user -s #{ENV['ORIGINAL_KEYCHAINS']}"

  end

end
