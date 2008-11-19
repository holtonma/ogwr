#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# copy as much as you want to
# 10-29-2008
# purpose: scrape the official world golf ranking, and present it in a more usable form (Array of ostruct's)
# using Hpricot, open-uri

require 'rubygems'
require 'hpricot'
require 'nokogiri'
require 'open-uri'
require 'ostruct'

module OGWR
  VERSION = '0.1.0'

  class Fetcher
    def fetch(ogwr_url, page_num)
      #page_num indicates range of 50n: page 1 >> 1-50, page 2 >> 51-100, page 3 >> 101-150...
      data = Hpricot(open(ogwr_url)).search("table:nth-child(5)")
      players = [] #init
      start_rank = -1 + 50*(page_num-1) #(there are 2 empty trs to start the world ranking) #instead of a counter, I should extract this from page
      (data/"td:nth-child(2)").each do |x|
        playa = OpenStruct.new
        playa.fname = x.search("a").inner_html.split(" ").first
        playa.lname = x.search("a").inner_html.split(" ")[1]
        playa.rank = start_rank
        #puts "#{playa.fname} #{playa.lname} #{playa.rank}"
        players << playa
        start_rank += 1
      end
      #clean this line up:
      players.pop; players.reverse!; players.pop; players.pop; players.reverse! #remove one extra row at end, 2 extra at beginning

      players
    end
    
    def fetch_via_noko(ogwr_url, page_num)
      doc = Nokogiri::HTML(open(ogwr_url))
      
      player_data = []
      cells = []
      
      doc.css("table").each do |table|
        if table.attributes['title'] == 'Click on player names to be taken to their individual tournaments page'
          table.css('tr').each do |row|
            row.css('td').each do |cel|
              innertext = cel.inner_text.strip()
              next unless innertext.length > 0
              #puts innertext
              cells << innertext
            end
            #puts cells
            player_data << cells
            cells = []
          end
          #puts "about to export player_data: "
        end
        #player_data
      end
      
      player_data
    end
    
    def friendly_structure player_data
      # take player_data and turn it into array of Ostructs
      players = []
      player_data.each do |p|
        #puts "p.class: #{p.class}"
        next unless (p.length > 0 && p[0] != "Rank")
        playa = OpenStruct.new
        # puts "element: #{p}"
        # puts "name: #{p[1]}"
        playa.rank = p[0]
        playa.fname = p[1].split(" ")[0]
        # puts "first name: #{p[1].split(" ")[0]}"
        # puts "last name: #{p[1].split(" ")[1]}" 
        playa.lname = p[1].split(" ")[1]
        # puts "Pts Avg: #{p[2]}"
        playa.avg_pts = p[2]
        # puts "tot pts: #{p[3]}"
        playa.tot_pts = p[3]
        # puts "num events: #{p[4]}"
        playa.num_events = p[4]
        # puts "pts lost 2006-07: #{p[5]}"
        playa.pts_lost_last_year = p[5]
        # puts "pts gained 2008: #{p[6]}"
        playa.pts_gained_this_year = p[6]
        players << playa
      end
      
      players
    end
    
    
  end
  
end






