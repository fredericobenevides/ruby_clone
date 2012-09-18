require 'spec_helper'

module RubyClone

  describe "FromFolder" do

    describe "#ssh?" do

      it "should return true if it has the option ssh setted" do
        from_folder = FromFolder.new('/from_folder', ssh: 'user@server')
        from_folder.ssh?.should be_true
      end

      it "should return false if it doesn't have the option ssh setted" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.ssh?.should be_false
      end
    end

    describe "#to_command" do

      it "should as default return empty string" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.to_command.should be_empty
      end

      it "should return '--exclude' when added" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.exclude_paths = '/exclude_path1'
        from_folder.exclude_paths = '/exclude_path2'

        from_folder.to_command.should == '--exclude=/exclude_path1 --exclude=/exclude_path2'
      end
    end

    describe "#to_s" do

      it "should return just the path name if ssh is not setted" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.to_s.should == '/from_folder'
      end

      it "should return just the path name if ssh is setted" do
        from_folder = FromFolder.new('/from_folder', ssh: 'user@server')
        from_folder.to_s.should == 'user@server:/from_folder'
      end
    end
  end

  describe "ToFolder" do

    describe "#ssh?" do

      it "should return true if it has the option ssh setted" do
        from_folder = FromFolder.new('/from_folder', ssh: 'user@server')
        from_folder.ssh?.should be_true
      end

      it "should return false if it doesn't have the option ssh setted" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.ssh?.should be_false
      end
    end

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

    describe "#to_s" do

      it "should return just the path name if ssh is not setted" do
        to_folder = ToFolder.new('/to_folder')
        to_folder.to_s.should == '/to_folder'
      end

      it "should return just the path name if ssh is setted" do
        to_folder = ToFolder.new('/to_folder', ssh: 'user@server')
        to_folder.to_s.should == 'user@server:/to_folder'
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