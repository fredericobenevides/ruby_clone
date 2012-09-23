require 'spec_helper'

module RubyClone

  describe BackupUtils do

    describe "#delete_files" do

      before(:each) do
        @ruby_clone_suffix = '_rbcl'

        @paths = [ "/my_path/sub_path1/file1#{@ruby_clone_suffix}_yesterday",
                   "/my_path/sub_path1/file1#{@ruby_clone_suffix}_today",
                   "/my_path/sub_path1/file2#{@ruby_clone_suffix}_yesterday",
                   "/my_path/sub_path2/file1#{@ruby_clone_suffix}_yesterday",
                   "/my_path/sub_path2/file2_rbcl_today"]

        BackupUtils.instance_eval { @find = Find }
        BackupUtils.instance_eval { @file_utils = FileUtils }

        Find.stub(:find).and_yield(@paths[0]).and_yield(@paths[1]).and_yield(@paths[2])
                        .and_yield(@paths[3]).and_yield(@paths[4])

      end

      describe "valid" do

        it "should create a hash with [path_files_without_suffix, path_files] that points to the files with same name" do
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 5)

          BackupUtils.instance_eval { @paths }.should == { '/my_path/sub_path1/file1' => [@paths[0], @paths[1]],
                                                           '/my_path/sub_path1/file2' => [@paths[2]],
                                                           '/my_path/sub_path2/file1' => [@paths[3]],
                                                           '/my_path/sub_path2/file2' => [@paths[4]] }
        end

        it "should delete old files with same name but different 'suffix' when passed the limit" do
          FileUtils.should_receive(:remove_entry).once
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 1)
        end

      end

      describe "invalid" do

        it "should not delete files with same name but different 'suffix' when it didn't pass the limit" do
          FileUtils.should_not_receive(:remove_entry)
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 5)
        end

        it "should not delete files with same name but different 'suffix' when the found files is on the limit" do
          FileUtils.should_not_receive(:remove_entry)
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 2)
        end

      end

    end

  end
end