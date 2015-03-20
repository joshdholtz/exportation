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

  class Export

    attr_accessor :path, :filename, :name, :password

    def initialize(options)
      @path = options[:path]
      @filename = options[:filename]
      @name = options[:name]
      @password = options[:password]
    end

    def run

      abs_path = File.expand_path path
      abs_path += '/' unless abs_path.end_with? '/'

      bash = "osascript #{Exportation.applescript_path} " +
        "\"#{abs_path}\" " +
        "\"#{filename}\" " +
        "\"#{name}\" " +
        "\"#{password}\" "

      puts "Running: #{bash}"
      `#{bash}`

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

          bash = "openssl aes-256-cbc -k \"#{password}\" -in #{file} -out #{output_file} -a"
          puts "Running: #{bash}"
          `#{bash}`
        else
          puts "File does not exist - #{file}"
        end
      end

    end

  end

end
