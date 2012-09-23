require 'spec_helper'

module RubyClone

  describe FromFolder do

    describe "#ssh?" do

      it "should return true if it has the option ssh set up" do
        from_folder = FromFolder.new('/from_folder', ssh: 'user@server')
        from_folder.ssh?.should be_true
      end

      it "should return false if it doesn't have the option ssh set up" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.ssh?.should be_false
      end
    end

    describe "#to_command" do

      it "should as default return empty string" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.to_command.should be_empty
      end

      it "should return '--exclude=/exclude_path1 --exclude=/exclude_path2' when exclude_paths are added" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.exclude_pattern = '/exclude_pattern1'
        from_folder.exclude_pattern = '/exclude_pattern2'

        from_folder.to_command.should == '--exclude=/exclude_pattern1 --exclude=/exclude_pattern2'
      end

      it "should return '--include=/include_path1 --include=/include_path2' when include_paths are added" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.include_pattern = '/include_pattern1'
        from_folder.include_pattern = '/include_pattern2'

        from_folder.to_command.should == '--include=/include_pattern1 --include=/include_pattern2'
      end

      it "should have --include before --exclude" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.include_pattern = '/include_pattern'
        from_folder.exclude_pattern = '/exclude_pattern'

        from_folder.to_command.should == '--include=/include_pattern --exclude=/exclude_pattern'
      end
    end

    describe "#to_s" do

      it "should return just the path name if ssh is not set up" do
        from_folder = FromFolder.new('/from_folder')
        from_folder.to_s.should == '/from_folder'
      end

      it "should return just the path name if ssh is set up" do
        from_folder = FromFolder.new('/from_folder', ssh: 'user@server')
        from_folder.to_s.should == 'user@server:/from_folder'
      end
    end
  end

  describe ToFolder do

    describe "#ssh?" do

      it "should return true if it has the option ssh set up" do
        to_folder = ToFolder.new('/to_folder', ssh: 'user@server')
        to_folder.ssh?.should be_true
      end

      it "should return false if it doesn't have the option ssh set up" do
        to_folder = ToFolder.new('/to_folder')
        to_folder.ssh?.should be_false
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

        it "should call the backup#to_command when it's associated" do
          to_folder = ToFolder.new('/to_folder/', delete: true)

          backup = double(:backup)
          to_folder.backup = backup

          backup.should_receive(:to_command).and_return('backup called')
          to_folder.to_command
        end

      end
    end

    describe "#to_s" do

      it "should return just the path name if ssh is not set up" do
        to_folder = ToFolder.new('/to_folder')
        to_folder.to_s.should == '/to_folder'
      end

      it "should return just the path name if ssh is set up" do
        to_folder = ToFolder.new('/to_folder', ssh: 'user@server')
        to_folder.to_s.should == 'user@server:/to_folder'
      end
    end
  end

  describe Backup do

    describe "#to_command" do

      it "should as default create the command '-b --suffix=rbcl_Date --backup-dir=/backup' with the ruby_clone suffix and the Date" do
        backup = Backup.new("/backup")
        backup.instance_eval { @time = '20120923'}
        backup.to_command.should == "-b --suffix=_rbcl_20120923 --backup-dir=/backup"
      end

      it "should not override the default ruby_clone suffix when using suffix option" do
        backup = Backup.new("/backup", suffix: "_my_suffix")
        backup.to_command.should == "-b --suffix=_rbcl_my_suffix --backup-dir=/backup"
      end

      it "should not create any suffix if the disable_suffix is true" do
        backup = Backup.new("/backup", suffix: "_my_suffix", disable_suffix: true)
        backup.to_command.should == "-b --backup-dir=/backup"
      end
    end

  end
end