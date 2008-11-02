
require 'ogwr_scraper'
require 'rubygems'
require 'test/unit'
require 'flexmock/test_unit'
require 'stringio'
require 'ostruct'

class TestOGWR < Test::Unit::TestCase
  include OGWR
  
  def setup
    # i really should mock this out and not hit the network... will do that later
    # page = 1
    # url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    # flexmock(fetcher).should_receive(:open).with(url, page).and_return{
    #   File.open(sample.html, 'r') 
    # }
  end
  
  def test_scrape_top50
    fetcher = PageFetcher.new
    page = 1
    url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    players = fetcher.fetch(url, page) 
    assert_equal 50, players.length
    assert_equal 1, players[0].rank
    assert_equal "Tiger", players[0].fname
    assert_equal "Woods", players[0].lname
  end
  
  def test_scrape_251to300
    fetcher = PageFetcher.new
    page = 6
    url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    players = fetcher.fetch(url, page) 
    assert_equal 50, players.length
    assert_equal 251, players[0].rank
    assert_equal "Ignacio", players[0].fname
    assert_equal "Garrido", players[0].lname
  end
  
end
