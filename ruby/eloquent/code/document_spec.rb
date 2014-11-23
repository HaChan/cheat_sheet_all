require "document"

describe Document do
  it "should not catch fire when creating an instance" do
    Document.new("title", "author", "stuff").should_not == nil
  end

  before :each do
    @text = "A bunch of words"
    @doc = Document.new "test", "nobody", @text
  end

  it "should hold on to the contents" do
    @doc.content.should == @text
  end

  it "should know which words it has" do
    @doc.words.should include "A"
    @doc.words.should include "bunch"
    @doc.words.should include "of"
    @doc.words.should include "words"
  end

  it "should know how many words it contains" do
    @doc.word_count.should == 4
  end

  it "should have a functional clone method" do
    doc1 = Document.new "title", "author", "some stuff"
    doc2 = doc1.clone
    doc2.title.should == "title"
    doc2.author.should == "author"
    doc2.content.should == "some stuff"
  end
end
