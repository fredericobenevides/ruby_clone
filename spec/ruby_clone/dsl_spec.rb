require 'spec_helper'

module RubyClone

  describe "Profile" do

    before(:all) do
      class DummyClass
      end
      DummyClass.extend RubyClone::DSL
    end

    describe "valid" do

      before(:each) do
        @profile = DummyClass.profile('backup') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end
      end

      it "should create with name 'backup'" do
        @profile.name.should == 'backup'
      end

      it "should create from folder with name '/from_folder' " do
        @profile.from_folder.path.should == '/from_folder'
      end

      it "should create to folder with name '/to_folder' " do
        @profile.to_folder.path.should == '/to_folder'
      end

    end

    describe "invalid" do

      it "should raise SyntaxError with message 'Empty Profile not allowed' for profile with no block" do
        lambda do
          DummyClass.profile('backup')
        end.should raise_error(SyntaxError, 'Empty Profile not allowed')
      end

      it "should raise SyntaxError with message 'Empty Profile not allowed' for empty block" do
        lambda do
          DummyClass.profile('backup') { }
        end.should raise_error(SyntaxError, 'Empty Profile not allowed')
      end
    end

    describe "exclude paths" do

      before(:each) do
        @rsync = DummyClass.rsync_new_instance
      end

      it "should create exclude paths for all profile if exclude is on the top" do
        DummyClass.exclude 'exclude_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == 'rsync -Cav --stats --exclude=exclude_top_path /from_folder /to_folder'
      end

      it "should create exclude paths for profile if exclude is not on the top" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.exclude 'exclude_backup1_path'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == 'rsync -Cav --stats --exclude=exclude_backup1_path /from_folder /to_folder'
        @rsync.rsync_command('backup2').should == 'rsync -Cav --stats /from_folder /to_folder'
      end

      it "should include the exclude path from the top and profile" do
        DummyClass.exclude 'exclude_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.exclude 'exclude_backup1_path'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == 'rsync -Cav --stats --exclude=exclude_top_path --exclude=exclude_backup1_path /from_folder /to_folder'
        @rsync.rsync_command('backup2').should == 'rsync -Cav --stats --exclude=exclude_top_path /from_folder /to_folder'
      end

    end
    
    describe "show_rsync_command" do

      it "should as default show the command in console" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        rsync = DummyClass.current_rsync
        rsync.show_rsync_command.should be_true
      end

      it "should not show the command in console when 'print_rsync_command' is false" do
        DummyClass.show_rsync_command false

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        rsync = DummyClass.current_rsync
        rsync.show_rsync_command.should be_false
      end
    end

  end

end