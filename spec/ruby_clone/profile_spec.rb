require 'spec_helper'

module RubyClone

  describe "ToFolder" do

    describe "#to_command" do

      it "should as default return empty string" do
        to_folder = ToFolder.new('/to_folder/')
        to_folder.to_command.should be_empty
      end

      it "should return '--delete' when the options delete is true" do
        to_folder = ToFolder.new('/to_folder/', delete: true)
        to_folder.to_command.should == "--delete"
      end

      it "should return '--delete-excluded' when the options delete_excluded is true" do
        to_folder = ToFolder.new('/to_folder/', delete_excluded: true)
        to_folder.to_command.should == "--delete-excluded"
      end

      describe "Backup association" do

        it "should call the backup#to_command when it's related" do
          to_folder = ToFolder.new('/to_folder/', delete: true)
          to_folder.backup = Backup.new("/backup")

          to_folder.to_command.should == "--delete -b --backup-dir=/backup"
        end

      end
    end
  end

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