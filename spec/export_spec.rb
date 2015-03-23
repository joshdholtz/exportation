require 'spec_helper'
describe Exportation::Export do

  describe "#run_command" do

    it "works with all parameters with relative path" do
      export = Exportation::Export.new(
        path: "path",
        filename: "filename",
        name: "name",
        password: "password"
      )
      bash = export.run_command

      path = File.join Dir.pwd, "path"
      expect(bash).to eq("osascript #{Exportation.applescript_path} " +
       "\"#{path}/\" " +
       "\"filename\" " +
       "\"name\" " +
       "\"password\"")
    end

    it "works with all parameters with absolute path" do
      export = Exportation::Export.new(
        path: "/path",
        filename: "filename",
        name: "name",
        password: "password"
      )
      bash = export.run_command

      expect(bash).to eq("osascript #{Exportation.applescript_path} " +
       "\"/path/\" " +
       "\"filename\" " +
       "\"name\" " +
       "\"password\"")
    end

    it "works with required parameters" do
      export = Exportation::Export.new(
        name: "name",
      )
      bash = export.run_command

      expect(bash).to eq("osascript #{Exportation.applescript_path} " +
       "\"#{Dir.pwd}/\" " +
       "\"exported\" " +
       "\"name\" " +
       "\"\"")
    end

    it "raises with missing parameters" do
      export = Exportation::Export.new({})

      expect {
        bash = export.run_command
      }.to raise_exception("name is required")
    end

  end

end
