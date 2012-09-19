require 'spec_helper'

module RubyClone

  describe "DSL" do

    before(:all) do
      class DummyClass
      end
      DummyClass.extend RubyClone::DSL

      @rsync_options = '-Cav --stats'
      @rsync_command = "rsync #{@rsync_options}"
      @folders = "/from_folder /to_folder"
    end

    before(:each) do
      @rsync = DummyClass.rsync_new_instance
    end

    describe "Creating a Profile" do

      describe "valid" do

        it "should create the following command 'rsync -Cav --stats /from_folder /to_folder'" do
          DummyClass.profile('backup1') do
            DummyClass.from('/from_folder')
            DummyClass.to('/to_folder')
          end

          @rsync.rsync_command('backup1').should == "#{@rsync_command} #{@folders}"
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
    end

    describe "#show_rsync_command" do

      it "should as default show the command in console" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.show_rsync_command.should be_true
      end

      it "should not show the command in console when 'print_rsync_command' is false" do
        DummyClass.show_rsync_command false

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.show_rsync_command.should be_false
      end
    end

    describe "#from" do

      it "should create exclude paths just for the profile 'backup1' if exclude DSL is not on the top" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.exclude_pattern '/exclude_pattern1'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --exclude=/exclude_pattern1 #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} #{@folders}"
      end

      it "should create include just for the profile 'backup1' if include_pattern DSL is setted only in the profile" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.include_pattern '/include_pattern1'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --include=/include_pattern1 #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} #{@folders}"
      end

      it "should have the following options '-e ssh user@server:/from_folder /to_folder' when is ssh" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder', ssh: "user@server")
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} -e ssh user@server:/from_folder /to_folder"
      end
    end

    describe "#to" do

      it "should have '--delete' when options 'delete' is setted" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder', delete: true)
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --delete #{@folders}"
      end

      it "should have '--delete-excluded' when options 'delete_excluded' is setted" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder', delete_excluded: true)
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --delete-excluded #{@folders}"
      end
    end

    describe "#exclude" do

      it "should create exclude paths for all profiles if exclude DSL is on the top" do
        DummyClass.exclude_pattern '/exclude_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --exclude=/exclude_top_path #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} --exclude=/exclude_top_path #{@folders}"
      end

      it "should include the exclude path from the top and profile if exclude DSL are setted in the top and in profile" do
        DummyClass.exclude_pattern 'exclude_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.exclude_pattern'/exclude_pattern1'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --exclude=exclude_top_path --exclude=/exclude_pattern1 #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} --exclude=exclude_top_path #{@folders}"
      end

    end

    describe "#include_pattern" do

      it "should create include for all profiles if include_pattern DSL is on the top" do
        DummyClass.include_pattern '/include_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --include=/include_top_path #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} --include=/include_top_path #{@folders}"
      end

      it "should create the include on the top and in profile if include_pattern DSL are setted in the top and in profile" do
        DummyClass.include_pattern '/include_top_path'

        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder') do
            DummyClass.include_pattern '/include_pattern1'
          end
          DummyClass.to('/to_folder')
        end

        DummyClass.profile('backup2') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder')
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} --include=/include_top_path --include=/include_pattern1 #{@folders}"
        @rsync.rsync_command('backup2').should == "#{@rsync_command} --include=/include_top_path #{@folders}"
      end

    end

    describe "#backup" do

      it "should include the backup commands when the backup is setted" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder') do
            DummyClass.backup('/backup_folder')
          end
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} -b --backup-dir=/backup_folder #{@folders}"
      end

      it "should include the suffix when the option is setted" do
        DummyClass.profile('backup1') do
          DummyClass.from('/from_folder')
          DummyClass.to('/to_folder') do
            DummyClass.backup('/backup_folder', suffix: 'my_suffix')
          end
        end

        @rsync.rsync_command('backup1').should == "#{@rsync_command} -b --suffix=my_suffix --backup-dir=/backup_folder #{@folders}"
      end
    end
  end
end