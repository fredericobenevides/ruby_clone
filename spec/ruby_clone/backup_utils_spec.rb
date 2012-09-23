require 'spec_helper'

module RubyClone

  describe BackupUtils do

    describe "#delete_files" do

      before(:each) do
        @ruby_clone_suffix = '_rbcl'

        @paths = [ "/my_path/sub_path1/file1#{@ruby_clone_suffix}_20120921",
                   "/my_path/sub_path1/file1#{@ruby_clone_suffix}_20120922",
                   "/my_path/sub_path1/file1#{@ruby_clone_suffix}_20120923",

                   "/my_path/sub_path1/file2#{@ruby_clone_suffix}_20120922",
                   "/my_path/sub_path2/file1#{@ruby_clone_suffix}_20120922",
                   "/my_path/sub_path2/file2#{@ruby_clone_suffix}_20120923"]

        File.stub(:exists?).with(any_args()).and_return(true)

        FileTest.stub(:file?).with(any_args()).and_return false
        FileTest.stub(:file?).with(@paths[0]).and_return true
        FileTest.stub(:file?).with(@paths[1]).and_return true
        FileTest.stub(:file?).with(@paths[2]).and_return true
        FileTest.stub(:file?).with(@paths[3]).and_return true
        FileTest.stub(:file?).with(@paths[4]).and_return true
        FileTest.stub(:file?).with(@paths[5]).and_return true

        Find.stub(:find).and_yield('/my_path').and_yield('/my_path/sub_path1')
                        .and_yield(@paths[0]).and_yield(@paths[1]).and_yield(@paths[2]).and_yield(@paths[3])
                        .and_yield('/my_path/sub_path2')
                        .and_yield(@paths[4]).and_yield(@paths[5])

      end

      describe "valid" do

        it "should create a hash with [path_files_without_suffix, path_files] that points to the files with same name" do
          paths = BackupUtils.find_files_with_same_name '/my_path', @ruby_clone_suffix

          paths.should == { '/my_path/sub_path1/file1' => [@paths[0], @paths[1], @paths[2]],
                            '/my_path/sub_path1/file2' => [@paths[3]],
                            '/my_path/sub_path2/file1' => [@paths[4]],
                            '/my_path/sub_path2/file2' => [@paths[5]] }
        end

        it "should delete old files with same name but different 'suffix' when passed the limit" do
          FileUtils.should_receive(:remove_entry).with(@paths[0])
          FileUtils.should_receive(:remove_entry).with(@paths[1])
          FileUtils.should_not_receive(:remove_entry).with(@paths[2])

          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 1)
        end

      end

      describe "invalid" do

        it "should not delete files with path that doesn't exist" do
          File.stub(:exists?).with(any_args()).and_return(false)
          Find.should_not_receive(:find)

          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 5)
        end

        it "should not delete files with same name but different 'suffix' when it didn't pass the limit" do
          FileUtils.should_not_receive(:remove_entry)
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 5)
        end

        it "should not delete files with same name but different 'suffix' when the found files is on the limit" do
          FileUtils.should_not_receive(:remove_entry)
          BackupUtils.delete_files('/my_path', @ruby_clone_suffix, 3)
        end

      end

    end

  end
end