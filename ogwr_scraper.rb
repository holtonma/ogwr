#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# copy as much as you want to
# 10-29-2008
# purpose: scrape the official world golf ranking, and present it in a more usable form (TBD: Array of Hashes, maybe)
# using Hpricot, open-uri

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'ostruct'
#require 'mysql'

module OGWR
  VERSION = '0.1.0'

  class PageFetcher
    def fetch(ogwr_url)
      data = Hpricot(open(ogwr_url)).search("table:nth-child(5)")
      players = [] #init
      start_rank = -1 #(there are 2 empty trs to start the world ranking) #instead of a counter, I should extract this from page
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

      players
    end
  end
  
end






