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

end
