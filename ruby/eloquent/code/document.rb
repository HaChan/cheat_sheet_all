class Document
  attr_accessor :writable, :read_only
  attr_accessor :title, :author, :content

  def initialize title, author, content
    @title = title
    @author = author
    @content = content
  end

  def words
    @content.split
  end

  def word_count
    words.size
  end

  def title= new_title
    @title = new_title if @writable
  end

  def add_authors *names
    @author << " #{names.join(' ')}"
  end

  def index_for word
    words.find_index { |this_word| word == this_word }
  end

  def average_word_length
    total = words.inject(0.0) {|result, word| result + word.size}
    total / word_count
  end

  def obscure_times!
    @content.gsub!( /\d\d:\d\d (AM|PM)/, '**:** **' )
  end

  def about_me
    puts "I am #{self}"
    puts "My title is #{self.title}"
    puts "I have #{self.word_count} words"
  end


  def clone
    Document.new title.clone, author.clone, content.clone
  end
end

