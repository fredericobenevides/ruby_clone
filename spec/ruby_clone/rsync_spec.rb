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
      @rsync = RSync.new('folder', 'backup_folder')
    end

    describe "#command" do

      it "should have -Cav --stats as rsync options" do
        @rsync.command.should ~/$rsync -Cav --stats/
      end

      it "should create rsync backup command from folder to backup_folder" do
        @rsync.command.should == 'rsync -Cav --stats folder backup_folder'
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

      it "should run the backup from 'folder' to 'backup_folder'" do
        FakerOpen4.stdin.as_null_object
        FakerOpen4.stdin.should_receive(:puts).with('rsync -Cav --stats folder backup_folder')
        FakerOpen4.stdin.should_receive(:close)

        FakerOpen4.stdout.should_receive(:read)
        FakerOpen4.stderr.should_receive(:read)

        @rsync.run
      end

    end
  end
end