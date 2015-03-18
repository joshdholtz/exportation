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

  class Encrypt

    attr_accessor :files, :password, :output

    def initialize(options)
      @files = options[:files]
      @password = options[:password]
      @output = options[:output]
    end

    def run

      files.each do |file|
          if File.exists? file
            output_file = file
            if output
              output_file = File.join(output, File.basename(file))
            end

            bash = "openssl aes-256-cbc -k \"#{password}\" -in #{file} -out #{output_file}.enc -a"
            puts "Running: #{bash}"
            `#{bash}`
          else
            puts "File does not exist - #{file}"
          end
      end

    end

  end

end
