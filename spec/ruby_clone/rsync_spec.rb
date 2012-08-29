require 'spec_helper'

module RubyClone

  describe "RSync" do
    describe "#command" do

      it "should have Cav as rsync options" do
        rsync = RSync.new('folder', 'backup_folder')
        rsync.command.should ~/$rsync -Cav/
      end

      it "should create rsync backup command from folder to backup_folder" do
        rsync = RSync.new('folder', 'backup_folder')
        rsync.command.should == 'rsync -Cav folder backup_folder'
      end

    end
  end
end