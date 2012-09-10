require 'spec_helper'


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
      from_folder = FromFolder.new "/from_folder"
      to_folder = ToFolder.new "/to_folder"

      @profile = Profile.new 'test_profile'
      @profile.from_folder = from_folder
      @profile.to_folder = to_folder

      @rsync = RSync.new
      @rsync.profiles = @profile
    end

    describe "#rsync_options" do

      it "should have -Cav --stats as rsync options" do
        @rsync.rsync_options.should == '-Cav --stats'
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
        @rsync.instance_eval { @open4 = FakerOpen4 }

        FakerOpen4.methods(false).grep(/(.*)=$/) do
          double_object = double($1)
          FakerOpen4.send "#{$1}=", double_object
        end
      end

      it "should run the backup from '/from_folder' to '/to_folder'" do
        FakerOpen4.stdin.as_null_object
        FakerOpen4.stdin.should_receive(:puts).with('rsync -Cav --stats /from_folder /to_folder')
        FakerOpen4.stdin.should_receive(:close)

        FakerOpen4.stdout.should_receive(:read)
        FakerOpen4.stderr.should_receive(:read)

        @rsync.run 'test_profile'
      end

    end
  end
end