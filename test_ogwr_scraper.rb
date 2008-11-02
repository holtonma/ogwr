
require 'ogwr_scraper'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'stringio'
require 'ostruct'

class TestOGWR < Test::Unit::TestCase
  include OGWR
  
  def setup
    # # 10 = default.  
    # @topend = 10
    # @number_generator = NumberGenerator.new(@topend)
    # @slot_machine = SlotMachine.new(@number_generator)
    
    # i really should mock this out and not hit the network... later
  end
  
  def test_scrape_top50
    fetcher = PageFetcher.new
    players = fetcher.fetch('http://www.officialworldgolfranking.com/rankings/default.sps') 
    assert_equal 50, players.length
    assert_equal 1, players[0].rank
    assert_equal "Tiger", players[0].fname
    assert_equal "Woods", players[0].lname
  end
  
end
