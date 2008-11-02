
require 'ogwr_scraper'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'stringio'

class TestOGWR < Test::Unit::TestCase
  include OGWR

  # test --- keep it from hitting the internet.  
  def test_fetch_ogwr
    fetcher = PageFetcher.new
    flexmock(fetcher).should_receive(:open).with('http://www.officialworldgolfranking.com/rankings/default.sps').and_return{
      StringIO.new('d=window.encodeURIComponent' * 500) #works on a string, ...returning something that has a read on it
    }
    data = fetcher.fetch('http://www.officialworldgolfranking.com/rankings/default.sps')
    assert data.length > 1000
    assert_match(/d=window.encodeURIComponen/, data)
    
    #doc = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    data = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    data.each do |x|; puts x.search("td:nth-child(n)"); puts x.search("td:nth-child(2)"); puts x.search("td:nth-child(3)"); puts x.search("td:nth-child(4)");  end
    
    (data/"td:nth-child(2)").each do |x|; puts x.search("a").inner_html; end
    # Tiger Woods
    # Phil Mickelson
    # Sergio Garcia
    # Vijay Singh
    # Padraig Harrington
    # Robert Karlsson
    #  ...
    (data/"td:nth-child(2)").each do |x|; puts x.search("a").inner_html.split(" ")[0]; end
    # Tiger
    # Phil
    # Sergio
    # Vijay
    # Padraig
    # Robert
    # ...
    
    # extract fname and lname of players
    data = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    players = [] #init
    (data/"td:nth-child(2)").each do |x|
      playa = OpenStruct.new
      playa.fname = x.search("a").inner_html.split(" ")[0]
      playa.lname = x.search("a").inner_html.split(" ")[1]
      puts "#{playa.fname} #{playa.lname}"
      players << playa
    end
    players.pop; players.reverse!; players.pop; players.pop; players.reverse! #remove one extra row at end, 2 extra at beginning
    
    #grab ranking
    data = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    data.each do |x|; puts x.search("td:nth-of-type(n)"); end
    
    data.each do |x|
      puts x.search("td:nth-of-type(n)") #rank
      puts x.search("td:nth-of-type(2)") #name
      puts x.search("td:nth-of-type(4)") #pts avg
      puts x.search("td:nth-of-type(6)") #total points
      puts x.search("td:nth-of-type(8)") #num of events
      puts x.search("td:nth-of-type(10)") #total points
    end
    
    #better:
    puts (data/"td:nth-child(2)"/"a").inner_html #link holding players name
    
    #data = doc.search("table:nth-child(5)")
    
    
    #data.search("tr:nth-child(2)") #Tiger Woods
    #data.search("tr:nth-child(3)") #Phil Mickelson
    
    #
    
  end
  
  def test_scrape_top50
    fetcher = PageFetcher.new
    doc = fetcher.fetch('http://www.officialworldgolfranking.com/rankings/default.sps')
    pp doc.search()
  end
  
  def setup
    # 10 = default.  
    @topend = 10
    @number_generator = NumberGenerator.new(@topend)
    @slot_machine = SlotMachine.new(@number_generator)
  end
  
  def test_slot_machine_uses_number_generator
    num_cherries = 3
    result = @slot_machine.pull_handle
    assert_equal(num_cherries, result.length)
    assert(result.all? { |x| (0..@topend) === x })
  end

  def test_number_generator_uses_rand
    # Make sure that rand is called
    flexmock(@number_generator).should_receive(:rand).with(@topend).times(3).and_return(5)

    # Make sure that rand always returns 5 in this test!
    result = @slot_machine.pull_handle
    assert(result.all? { |x| x == 5 })
  end
end
