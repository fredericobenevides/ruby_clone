require 'spec_helper'
require 'stringio'

class FakerOpen4

  class << self
    attr_accessor :pid, :stdin, :stdout, :stderr, :status

    def popen4(output, &block)
      block.call @pid, @stdin, @stdout, @stderr
      status
    end
  end
end

module RubyClone

  describe "RSync" do

    before(:each) do
      @from_folder = FromFolder.new "/from_folder"
      @to_folder = ToFolder.new "/to_folder"

      @profile = Profile.new 'test_profile'
      @profile.from_folder = @from_folder
      @profile.to_folder = @to_folder

      @output = StringIO.new
      @rsync = RSync.new(@output)
      @rsync.profiles = @profile
    end

    describe "#rsync_options" do

      it "should have -Cav --stats as rsync options" do
        @rsync.rsync_options.should == '-Cav --stats'
      end

    end
    
    describe "#rsync_command" do

      it "should create with the default command" do
        command = @rsync.rsync_command "test_profile"
        command.should == "rsync -Cav --stats /from_folder /to_folder"
      end

      describe "exclude paths" do

        it "should create with '--exclude' options when setted the excluded path" do
          @rsync.exclude_paths = 'exclude1'
          @rsync.exclude_paths = 'exclude2'

          command = @rsync.rsync_command "test_profile"
          command.should == "rsync -Cav --stats --exclude=exclude1 --exclude=exclude2 /from_folder /to_folder"
        end

        it "should insert the exclude paths from the rsync and from the profile if they are setted" do
          @rsync.exclude_paths = 'exclude1'
          @rsync.exclude_paths = 'exclude2'

          @rsync.last_profile.from_folder.exclude_paths = 'exclude3'
          @rsync.last_profile.from_folder.exclude_paths = 'exclude4'

          command = @rsync.rsync_command "test_profile"
          command.should == "rsync -Cav --stats --exclude=exclude1 --exclude=exclude2 --exclude=exclude3 --exclude=exclude4 /from_folder /to_folder"
        end

        it "should insert the exclude paths just for the profile when rsync doesn't have it" do
          @rsync.last_profile.from_folder.exclude_paths = 'exclude3'
          @rsync.last_profile.from_folder.exclude_paths = 'exclude4'

          command = @rsync.rsync_command "test_profile"
          command.should == "rsync -Cav --stats --exclude=exclude3 --exclude=exclude4 /from_folder /to_folder"
        end
      end

      describe "ToFolder association" do

        it "should call to_folder#to_commands" do
          to_folder = double(:to_folder)
          @profile.to_folder = to_folder


          to_folder.should_receive :to_command
          @rsync.rsync_command "test_profile"
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

      describe "valid" do

        before(:each) do
          @rsync.instance_eval { @open4 = FakerOpen4 }

          FakerOpen4.methods(false).grep(/(.*)=$/) do
            double_object = double($1)
            FakerOpen4.send "#{$1}=", double_object
          end

          FakerOpen4.stdin.should_receive(:puts).with('rsync -Cav --stats /from_folder /to_folder')
          FakerOpen4.stdin.should_receive(:close)

          FakerOpen4.stdout.should_receive(:read)
          FakerOpen4.stderr.should_receive(:read)
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

        it "should as default show the rsync command in console" do
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == "\nrsync -Cav --stats /from_folder /to_folder\n\n"
        end

        it "should not print the rsync command in console when 'show_rsync_command' is false" do
          @rsync.show_rsync_command = false
          @rsync.run 'test_profile'

          @output.seek 0
          @output.read.should == ""
        end

      end

      describe "invalid" do

        it "should raise ArgumentError when trying to run a profile that doesn't exist" do
          lambda do
            @rsync.run 'any'
          end.should raise_error(ArgumentError, "Profile not found")
        end

        it "should raise SyntaxError with message 'Empty Profile not allowed for profile with no 'from folder''" do
          lambda do
            profile = Profile.new 'no_from_folder'
            profile.to_folder = @to_folder
            @rsync.profiles = profile

            @rsync.run 'no_from_folder'
          end.should raise_error(SyntaxError, "Empty Profile not allowed for profile with no 'from folder'")
        end

        it "should raise SyntaxError with message 'Empty Profile not allowed for profile with no 'to folder''" do
          lambda do
            profile = Profile.new 'no_to_folder'
            profile.from_folder = @from_folder
            @rsync.profiles = profile

            @rsync.run 'no_to_folder'
          end.should raise_error(SyntaxError, "Empty Profile not allowed for profile with no 'to folder'")
        end

      end

    end
  end
end