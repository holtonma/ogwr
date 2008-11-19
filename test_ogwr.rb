
require 'ogwr'
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
    fetcher = Fetcher.new
    page = 1
    url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    players = fetcher.fetch(url, page) 
    assert_equal 50, players.length
    assert_equal 1, players[0].rank
    assert_equal "Tiger", players[0].fname
    assert_equal "Woods", players[0].lname
  end
  
  def test_scrape_251to300
    fetcher = Fetcher.new
    page = 6
    url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    players = fetcher.fetch(url, page) 
    assert_equal 50, players.length
    assert_equal 251, players[0].rank
    assert_equal "Marc", players[0].fname
    assert_equal "Warren", players[0].lname
  end
  
  def test_via_noko
    fetcher = Fetcher.new
    page = 6
    url = "http://www.officialworldgolfranking.com/rankings/default.sps?region=world&PageCount=#{page}"
    puts fetcher.fetch_via_noko(url, page) 
  end
  
  
end
