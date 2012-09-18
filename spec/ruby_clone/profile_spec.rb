require 'spec_helper'

module RubyClone

  describe "Backup" do

    describe "#to_command" do

      it "should as default create the command '-b --backup-dir=/backup'" do
        backup = Backup.new("/backup")
        backup.to_command.should == "-b --backup-dir=/backup"
      end

      it "should create the command '-b --suffix=my_suffix --backup-dir=/backup' when using suffix" do
        backup = Backup.new("/backup", suffix: "my_suffix")
        backup.to_command.should == "-b --suffix=my_suffix --backup-dir=/backup"
      end
    end

  end
end