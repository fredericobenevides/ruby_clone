require 'spec_helper'
require 'stringio'

class FakerPTY
  class << self
      attr_accessor :r, :w, :pid

      def spawn(command, &block)
        block.call @r, @w, @pid
      end
    end
end

module RubyClone

  describe RSync do

    before(:each) do
      @from_folder = FromFolder.new "/from_folder"
      @to_folder = ToFolder.new "/to_folder"

      @profile = Profile.new 'test_profile'
      @profile.from_folder = @from_folder
      @profile.to_folder = @to_folder

      @output = StringIO.new
      @rsync = RSync.new(@output)
      @rsync.profiles = @profile

      @rsync_options = '-Cavh --stats --progress'
      @rsync_command = "rsync #{@rsync_options}"
      @folders = "/from_folder /to_folder"
    end

    describe "#configurations" do

      it "should as default have '-Cav --stats' in options" do
        @rsync.instance_eval { @configurations[:options] }.should == "#{@rsync_options}"
      end

      it "should as default have 'true' in show_command" do
        @rsync.instance_eval { @configurations[:show_command] }.should be_true
      end

      it "should as default have 'true' in show_output" do
        @rsync.instance_eval { @configurations[:show_output] }.should be_true
      end
    end

    describe "#rsync_command" do

      describe "profile invalid" do

        it "should raise ArgumentError when trying to run a profile that doesn't exist" do
          lambda do
            @rsync.run 'my_profile'
          end.should raise_error(ArgumentError, "Profile my_profile not found")
        end

        it "should raise SyntaxError with message 'Empty Profile not allowed for profile no_from_folder with no 'from folder''" do
          lambda do
            profile = Profile.new 'no_from_folder'
            profile.to_folder = @to_folder
            @rsync.profiles = profile

            @rsync.run 'no_from_folder'
          end.should raise_error(SyntaxError, "Empty Profile not allowed for profile no_from_folder with no 'from folder'")
        end

        it "should raise SyntaxError with message 'Empty Profile not allowed for profile no_to_folder with no 'to folder''" do
          lambda do
            profile = Profile.new 'no_to_folder'
            profile.from_folder = @from_folder
            @rsync.profiles = profile

            @rsync.run 'no_to_folder'
          end.should raise_error(SyntaxError, "Empty Profile not allowed for profile no_to_folder with no 'to folder'")
        end
      end

      it "should as default create the command 'rsync -Cav --stats /from_folder /to_folder'" do
        command = @rsync.rsync_command "test_profile"
        command.should == "#{@rsync_command} #{@folders}"
      end

      describe "appending commands" do

        it "should create with '--exclude=/exclude_path1 --exclude=/exclude_path2' options when set up the excluded path" do
          @rsync.exclude_pattern = '/exclude_pattern1'
          @rsync.exclude_pattern = '/exclude_pattern2'

          command = @rsync.rsync_command "test_profile"
          command.should == "#{@rsync_command} --exclude=/exclude_pattern1 --exclude=/exclude_pattern2 #{@folders}"
        end

        it "should create with '--include' when set up the include pattern" do
          @rsync.include_pattern = '/include_pattern1'
          @rsync.include_pattern = '/include_pattern2'

          command = @rsync.rsync_command "test_profile"
          command.should == "#{@rsync_command} --include=/include_pattern1 --include=/include_pattern2 #{@folders}"
        end

        it "should have --include before the --exclude" do
          @rsync.exclude_pattern = '/exclude_pattern'
          @rsync.include_pattern = '/include_pattern'

          command = @rsync.rsync_command "test_profile"
          command.should == "#{@rsync_command} --include=/include_pattern --exclude=/exclude_pattern #{@folders}"
        end

        describe "FromFolder association" do

          it "should appends the commands from 'from_folder#to_commands'" do
            @rsync.exclude_pattern = '/exclude_pattern1'
            @rsync.exclude_pattern = '/exclude_pattern2'

            from_folder = double(:from_folder).as_null_object
            from_folder.stub(:ssh?).and_return false
            from_folder.stub(:to_s).and_return '/from_folder'
            from_folder.should_receive(:to_command).and_return('from_folder#to_command')

            @profile.from_folder = from_folder

            command = @rsync.rsync_command "test_profile"
            command.should == "#{@rsync_command} --exclude=/exclude_pattern1 --exclude=/exclude_pattern2 from_folder#to_command #{@folders}"
          end
        end

        describe "ToFolder association" do

          it "should call to_folder#to_commands" do
            @rsync.exclude_pattern = '/exclude_pattern1'
            @rsync.exclude_pattern = '/exclude_pattern2'

            to_folder = double(:to_folder).as_null_object
            to_folder.stub(:ssh?).and_return false
            to_folder.stub(:to_s).and_return '/to_folder'
            to_folder.should_receive(:to_command).and_return('to_folder#to_command')

            @profile.to_folder = to_folder

            command = @rsync.rsync_command "test_profile"
            command.should == "#{@rsync_command} --exclude=/exclude_pattern1 --exclude=/exclude_pattern2 to_folder#to_command #{@folders}"
          end

        end
      end

      describe "using ssh" do

        it "should have the ssh in the rsync command when FromFolder is using ssh" do
          from_folder = FromFolder.new "/from_folder", ssh: "user@server"
          @profile.from_folder = from_folder

          command = @rsync.rsync_command "test_profile"
          command.should == "#{@rsync_command} -e ssh user@server:/from_folder /to_folder"
        end

        it "should have the ssh in the rsync command when ToFolder is using ssh" do
          to_folder = ToFolder.new "/to_folder", ssh: "user@server"
          @profile.to_folder = to_folder

          command = @rsync.rsync_command "test_profile"
          command.should == "#{@rsync_command} -e ssh /from_folder user@server:/to_folder"
        end

        it "should raise SyntaxError if the source and destination is ssh" do
          lambda do
            from_folder = FromFolder.new "/from_folder", ssh: "user@server"
            @profile.from_folder = from_folder

            to_folder = ToFolder.new "/to_folder", ssh: "user@server"
            @profile.to_folder = to_folder

            @rsync.rsync_command "test_profile"
          end.should raise_error(SyntaxError, 'The source and destination cannot both be remote.')
        end
      end
    end

    describe "#last_profile" do

      it "should return the last profile added" do
        @rsync.last_profile.should == @profile

        other_profile = Profile.new 'other_profile'

        @rsync.profiles = other_profile
        @rsync.last_profile.should == other_profile
      end
    end

    describe "#run" do


      before(:each) do
        @rsync.instance_eval { @pty = FakerPTY }

        FakerPTY.methods(false).grep(/(.*)=$/) do
          double_object = double($1)
          FakerPTY.send "#{$1}=", double_object
        end

        FakerPTY.r.stub(:each).and_yield(nil)
        FakerPTY.r.stub(:eof?).and_return(false, true)
        FakerPTY.r.stub(:getc).and_return('')
      end

      describe "profile of string type" do

        before(:each) do
          profile = Profile.new 'profile_string'
          profile.from_folder = @from_folder
          profile.to_folder = @to_folder

          @rsync.profiles = profile
        end

        it "should run using profile as string" do
          @rsync.run 'profile_string'
        end

        it "should run using profile as symbol" do
          @rsync.run :profile_string
        end
      end

      describe "profile of symbol type" do

        before(:each) do
          profile = Profile.new :profile_symbol
          profile.from_folder = @from_folder
          profile.to_folder = @to_folder

          @rsync.profiles = profile
        end

        it "should run using profile as string" do
          @rsync.run 'profile_symbol'
        end

        it "should run using profile as symbol" do
          @rsync.run :profile_symbol
        end

      end

      describe "changing configurations" do

        it "should change the rsync options when configurations has 'options' as '-a'" do
          @rsync.update_configurations options: "-a"
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\nrsync -a #{@folders}\n\n"
        end

        it "should as default show the rsync command in console" do
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\n#{@rsync_command} #{@folders}\n\n"
        end

        it "should not print the rsync command in console when configurations has 'show_command' as false" do
          @rsync.update_configurations show_command: false
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == ""
        end

        it "should as default output the rsync results in console" do
          FakerPTY.r.stub(:getc).and_return('my result')

          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\n#{@rsync_command} #{@folders}\n\nmy result"
        end

        it "should not output the rsync results in console when configurations has 'show_output' as false" do
          FakerPTY.r.should_not_receive(:each)

          @rsync.update_configurations show_output: false
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\n#{@rsync_command} #{@folders}\n\n"
        end
      end

      it "should allow the user to fill a password" do
        FakerPTY.r.stub(:eof?).and_return(false, false, true)
        FakerPTY.r.should_receive(:getc).and_return('Password:', 'my result')

        FakerPTY.w.should_receive(:printf).with('my password')

        STDIN.stub(:gets).and_return('my password')

        @rsync.run 'test_profile'

        @output.seek 0
        @output.read.should == "\n#{@rsync_command} #{@folders}\n\nPassword: my result"
      end

      it "should keep allowing the user to fill a password if it's asked again" do
        FakerPTY.r.stub(:eof?).and_return(false, false, false, false, true)
        FakerPTY.r.should_receive(:getc).and_return('Password:', 'Password:', 'Password:', 'my result')

        FakerPTY.w.stub(:printf).with('my password')

        STDIN.stub(:gets).and_return('my password')

        @rsync.run 'test_profile'

        @output.seek 0
        @output.read.should == "\n#{@rsync_command} #{@folders}\n\nPassword: Password: Password: my result"
      end

      it "should quit the running program after throwing Errno::EIO" do
        FakerPTY.r.stub(:eof?).and_raise(Errno::EIO)
        FakerPTY.r.stub(:getc).and_return('my result')

        @rsync.run 'test_profile'

        @output.seek 0
        @output.read.should == "\n#{@rsync_command} #{@folders}\n\n"
      end

      describe "dry-run mode" do

        it "should have the option '-n'" do
          @rsync.dry_run = true

          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\n#{@rsync_command} -n #{@folders}\n\n"
        end

        it "should not delete files from backup folder if it's in dry-run mode" do
          @rsync.dry_run = true
          @to_folder.should_not_receive(:delete_files)

          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\n#{@rsync_command} -n #{@folders}\n\n"
        end

        it "should call profile#to_folder#delete_files if it's not in dry-run mode" do
          @to_folder.should_receive(:delete_files)

          @rsync.run 'test_profile'
        end
      end
    end

  end
end