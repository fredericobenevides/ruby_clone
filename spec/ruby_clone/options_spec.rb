require 'spec_helper'
require 'stringio'

module RubyClone

  describe Options do

    before(:each) do
      @output = StringIO.new
      @options = Options.new(@output)
    end

    describe "Help messages" do

      it "should show if ARGV is empty" do
        opts = @options.parse([])
        opts.on.to_s.should =~ /-h, --help\s+This message.*/
      end

      it "should show if ARGV have the option '-h'" do
       @options.parse(%w[-h])

        @output.seek 0
        @output.read.should =~ /-h, --help\s+This message.*/
      end

      it "should not show if ARGV have another option that exists and is not '-h'" do
        @options.parse(%w[-b /my_file])

        @output.seek 0
        @output.read.should_not =~ /-h, --help\s+This message.*/
      end

      it "should have the banner with message 'Usage: ruby_clone [options] profile'" do
        opts = @options.parse([])
        opts.banner.should == 'Usage: ruby_clone [options] profile'
      end
    end

    describe "Backup file" do

      it "should as default the backup file path be '~/.ruby_clone'" do
        @options.parse(%w[backup_profile])
        @options.configurations[:backup_file].should == '~/.ruby_clone'
      end

      it "should set a new backup file location with the options is '-b'" do
        @options.parse(%w[-b /my_file backup_profile])
        @options.configurations[:backup_file].should == '/my_file'
      end
    end

    it "should set dry-run mode when the option is '-d'" do
      @options.parse(%w[-d])
      @options.configurations[:dry_run].should be_true
    end

  end

end