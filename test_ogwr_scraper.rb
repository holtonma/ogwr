
require 'ogwr_scraper'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'stringio'
require 'ostruct'

class TestOGWR < Test::Unit::TestCase
  include OGWR

  # test --- keep it from hitting the internet.  
  def test_fetch_ogwr
    
    # extract fname and lname of players
    data = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    #data.pop; data.reverse!; data.pop; data.pop; data.reverse! #remove one extra row at end, 2 extra at beginning
    players = [] #init
    start_rank = -1 #(there are 2 empty trs to start the world ranking)
    (data/"td:nth-child(2)").each do |x|
      playa = OpenStruct.new
      playa.fname = x.search("a").inner_html.split(" ")[0]
      playa.lname = x.search("a").inner_html.split(" ")[1]
      playa.rank = start_rank
      puts "#{playa.fname} #{playa.lname} #{playa.rank}"
      players << playa
      start_rank += 1
    end
    players.pop; players.reverse!; players.pop; players.pop; players.reverse! #remove one extra row at end, 2 extra at beginning
    
    pp players
    
    pp players[30].lname
    
    # players = [] #init
    # #ranking, strip any nbsp;
    # data.each do |x|
    #   playa = OpenStruct.new
    #   #puts x.search("td:nth-of-type(1)").inner_html.strip.gsub(/&nbsp;/, "")
    #   playa.rank = x.search("td:nth-of-type(1)").inner_html.strip.gsub(/&nbsp;/, "")
    #   playa.fname = x.search("td:nth-of-type(3)").search("a").inner_html.strip.gsub(/&nbsp;/, "").split(" ")[0]
    #   playa.lname = x.search("td:nth-of-type(3)").search("a").inner_html.strip.gsub(/&nbsp;/, "").split(" ")[1]
    #   puts "Playa info --- #{playa.rank}::#{playa.fname} #{playa.lname}"
    #   #puts x.search("td:nth-of-type(3)").search("a").inner_html.strip.gsub(/&nbsp;/, "")
    # end
    # 
    # test = "&nbsp;12&nbsp;"
    # result = test.strip.gsub(/&nbsp;/, "")
    # puts "reg exp: #{result}"
    
    #grab ranking
    # data = Hpricot(open("http://www.officialworldgolfranking.com/rankings/default.sps")).search("table:nth-child(5)")
    # data.each do |x|; puts x.search("td:nth-of-type(n)"); end
    #     
      # puts x.search("td:nth-of-type(1)") #rank
      # puts x.search("td:nth-of-type(2)") #name
      # puts x.search("td:nth-of-type(4)") #pts avg
      # puts x.search("td:nth-of-type(6)") #total points
      # puts x.search("td:nth-of-type(8)") #num of events
      # puts x.search("td:nth-of-type(10)") #total points

  end
  
  def test_scrape_top50
    fetcher = PageFetcher.new
    doc = fetcher.fetch('http://www.officialworldgolfranking.com/rankings/default.sps')
    #pp doc.search()
  end
  
  def setup
    # # 10 = default.  
    # @topend = 10
    # @number_generator = NumberGenerator.new(@topend)
    # @slot_machine = SlotMachine.new(@number_generator)
  end
  
  
end
