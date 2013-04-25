require 'spec_helper'

describe Spree::Hominid::Configuration do

  context "enabled" do
    before  { Spree::Hominid::Interface::List.should_receive(:new).any_number_of_times.with('1234', 'Members').and_return(:interface) }
    subject { config(key: '1234', list_name: 'Members') }

    specify              { should be_enabled }
    its(:list_interface) { should == :interface }
  end

  context "disabled" do
    subject { config(key: nil) }

    specify              { should_not be_enabled }
    its(:list_interface) { should be_nil }
  end

  context "sync merge vars" do
    let(:interface)     { mock(:interface) }
    let(:configuration) { config(key: '1234',
                                 list_name: 'Members',
                                 merge_vars: {'EMAIL' => :email, 'FNAME' => :first_name, 'LNAME' => :last_name})}
    before { Spree::Hominid::Interface::List.should_receive(:new).any_number_of_times.with('1234', 'Members').and_return(interface) }

    it "adds var for each" do
      interface.should_receive(:merge_vars).and_return([])
      interface.should_receive(:add_merge_var).with('FNAME', 'First Name')
      interface.should_receive(:add_merge_var).with('LNAME', 'Last Name')

      configuration.sync_merge_vars
    end

    it "skips vars that exist" do
      interface.should_receive(:merge_vars).and_return(%w(EMAIL FNAME))
      interface.should_receive(:add_merge_var).with('LNAME', 'Last Name')

      configuration.sync_merge_vars
    end

    it "doesnt sync if all exist" do
      interface.should_receive(:merge_vars).and_return(%w(EMAIL FNAME LNAME))
      interface.should_not_receive(:add_merge_var)

      configuration.sync_merge_vars
    end
  end

  def config(options = {})
    config = Spree::Hominid::Configuration.new
    config.preferred_key        = options[:key]
    config.preferred_list_name  = options[:list_name]
    config.preferred_merge_vars = options[:merge_vars]
    config
  end
end