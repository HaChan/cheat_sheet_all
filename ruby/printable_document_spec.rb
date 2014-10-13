require "printable_document"

describe PrintableDocument do
  before :each do
    @text = "A bunch of words"
    @doc = PrintableDocument.new "test", "nobody", @text
  end

  it "should know how to print itself" do
    stub_printer = stub :available? => true, render: nil
    @doc.print(stub_printer).should == "Done"
  end

  it "should return the proper string if printer is offline" do
    stub_printer = stub :available? => false, render: nil
    @doc.print(stub_printer).should == "Printer unavailable"
  end

  it "should know how to print itself" do
    mock_printer = mock "Printer"
    mock_printer.should_receive(:available?).and_return true
    mock_printer.should_receive(:render).exactly(3).times
    @doc.print(mock_printer).should == "Done"
  end

end
