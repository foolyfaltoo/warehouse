require File.join(File.dirname(__FILE__), 'spec_helper')
require 'silo/adapters/svn'

describe Silo::Adapters::Svn do
  before do
    @repo = Silo::Repository.new(:svn, $adapter_options[:svn])
  end

  it "sets adapter with type and options hash" do
    repo = Silo::Repository.new(:svn, :foo => :bar)
    (class << repo ; self ; end).should include(Silo::Adapters::Svn)
    repo.options[:foo].should == :bar
  end

  it "retrieves latest revision" do
    @repo.latest_revision.should == 2
  end
  
  it "retrieves mime type from adapter if possible" do
    @repo.mime_type_for(@repo.node_at('test.html')).should =~ /html/
  end
  
  it "retrieves mime type from file name as a fallback" do
    @repo.mime_type_for(@repo.node_at("foo/bar/baz.txt")).should == 'txt'
  end

  it "checks if node exists" do
    @repo.exists?(@repo.node_at("foo")).should     == true
    @repo.exists?(@repo.node_at("foo/bar")).should == false
  end
  
  it "checks if node is a directory?" do
    @repo.exists?(@repo.node_at("foo")).should     == true
    @repo.exists?(@repo.node_at("foo/bar")).should == false
  end

  it "retrieves blame information" do
    @repo.blame_for(@repo.node_at("test.html")).should == {1 => [1, 'rick'], 2 => [2, 'rick'], :username_length => 4}
  end
  
  it "retrieves child node names" do
    children = @repo.child_node_names_for(@repo.node_at("/"))
    children.should include('foo')
    children.should include("config.yml")
    children.should include("test.html")
  end

  {:latest_revision => 2, :author => 'rick', :changed_at => Time.utc(2008, 1, 3, 0, 46, 39, 151238), :message => 'booya'}.each do |attr, value|
    it "retrieves ##{attr} for given path" do
      @repo.send("#{attr}_for", @repo.node_at('test.html')).should == value
    end
  end
  
  it "reads contents of node" do
    @repo.content_for(@repo.node_at("config.yml")).should == IO.read(File.join(File.dirname(__FILE__), 'mock_repo', 'config.yml'))
  end
end