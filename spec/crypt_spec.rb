require 'spec_helper'
describe Exportation::Crypter do

  describe "Encrypt" do

    describe "#run_commands" do

      it "works with all parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer", "spec/fixtures/file1.p12"],
          password: "password",
          output: "output"
        )
        commands = cypter.run_commands :en

        expect(commands[0]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.cer -out output/file1.cer.enc -a")
        expect(commands[1]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.p12 -out output/file1.p12.enc -a")
      end

      it "works with required parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer", "spec/fixtures/file1.p12"],
          password: "password",
        )
        commands = cypter.run_commands :en

        expect(commands[0]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.cer -out ./spec/fixtures/file1.cer.enc -a")
        expect(commands[1]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.p12 -out ./spec/fixtures/file1.p12.enc -a")
      end

      it "raises with missing parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer", "spec/fixtures/file1.p12"],
        )

        expect {
          commands = cypter.run_commands :en
        }.to raise_exception("password is required")
      end

    end

  end

  describe "Decrypt" do

    describe "#run_commands" do

      it "works with all parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer.enc", "spec/fixtures/file1.p12.enc"],
          password: "password",
          output: "output"
        )
        commands = cypter.run_commands :de

        expect(commands[0]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.cer.enc -out output/file1.cer -a -d")
        expect(commands[1]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.p12.enc -out output/file1.p12 -a -d")
      end

      it "works with required parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer.enc", "spec/fixtures/file1.p12.enc"],
          password: "password",
        )
        commands = cypter.run_commands :de

        expect(commands[0]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.cer.enc -out ./spec/fixtures/file1.cer -a -d")
        expect(commands[1]).to eq("openssl aes-256-cbc -k \"password\" -in ./spec/fixtures/file1.p12.enc -out ./spec/fixtures/file1.p12 -a -d")
      end

      it "raises with missing parameters" do
        cypter = Exportation::Crypter.new(
          files: ["spec/fixtures/file1.cer.enc", "spec/fixtures/file1.p12.enc"],
        )

        expect {
          commands = cypter.run_commands :de
        }.to raise_exception("password is required")
      end

    end

  end

end
