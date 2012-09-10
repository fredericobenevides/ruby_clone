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

  end

end