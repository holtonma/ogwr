#!/usr/bin/env ruby -w
# created by Mark Holton  (holtonma@gmail.com)
# copy as much as you want to
# 10-29-2008
# purpose: scrape the official world golf ranking, and present it in a more usable form (TBD: Array of Hashes, maybe)
# using Hpricot, open-uri

require 'rubygems'
require 'hpricot'
require 'open-uri'
#require 'mysql'

module OGWR
  VERSION = '0.1.0'

  class PageFetcher
    def fetch(ogwr_url)
      #open(ogwr_url).read
      Hpricot(open(ogwr_url))
      #open('http://www.officialworldgolfranking.com/rankings/default.sps').read
    end
  end

  class SlotMachine
    # 
    def initialize(num_gen)
      @number_generator = num_gen
      @cherries = []
    end
    
    def pull_handle(num=3)
      #another possible implementation (in class): [](0,3){ @number_generator.random_number }
      num.times do
        @cherries << @number_generator.random_number 
      end
      @cherries
    end
  end
  
  class NumberGenerator
    def initialize(number=10)
      @number = number
    end
    
    def random_number(limit=@number)
      rand(limit)
    end
  end
end



class Leaderboard
  def initialize file_or_url, root_path, leaderboard_path=""
    @file_or_url = file_or_url #this smells
    @root_path = root_path
    @leaderboard_path = leaderboard_path
    @leaders = []
    @name = ""
    @score = 0
  end
  
  attr_accessor :root_path, :leaderboard_path, :leaders
  
  def populate
    if (@file_or_url == "file")
      file = open("test_index.html") { |f| Hpricot(f) }
      doc = Hpricot(file.to_html)
      elements = doc.search("/html/body//p")
      #puts elements
      all_rows = doc.search("//div[@class='leaderMain']/div/table/tbody/tr")
    else
      doc = Hpricot(open(@root_path + @leaderboard_path))
      #all_rows = doc.search(".leaderMain/tr")
      all_rows = doc.search("//.leaderMain/tr")
    end

    
    all_rows.each do |row|
      tds = (row/"td")
      player = {}
      
      i = 0
      tds.each do |col|
        i += 1
        #puts col
        
        #puts "#{i}"
        #puts "col: #{col}"
        
        if i == 1
          player[:pos] = col.inner_html
          puts "pos: #{player[:pos]}"
        end
        if i == 3
          if player[:pos] != "WD"
          #puts "col: #{(col)}"
          #puts "col/'a': #{(col/"a")}"
          #puts "col/'a/img': #{(col/"a/img")}"
          #puts "col//'a': #{(col/"//a")}"
          #puts "col/'a:last': #{(col/"a:last")}"
          if (col/"a:last") != nil
            player[:name] = (col/"a:last").inner_html #(col/"a").inner_html
            player[:name] = "Prayad Marksaeng" if player[:name] == nil
            #puts player[:name]
          else
            player[:name] = ""
            #puts "player blank"
          end
          #names = self.split_name(pla)
          else
            player[:name] = "WD"
          end
        end
        if i == 4
          player[:total] = col.inner_html
          puts "total: #{player[:total]}"
          @leaders << player
          #update score here 
        end
        if i == 5
          if player[:pos] != "WD"
            player[:thru] = col.inner_html
          else
            player[:thru] = "-"
          end
          puts player[:thru]
          puts "#{player[:name]}, #{player[:total]}, #{player[:thru]}, #{player[:pos]}"
          if player[:name] != "WD"
            self.update_db(player[:name], player[:total], player[:thru], player[:pos])
          end
        end
        
        #puts "added #{col}"
        
      end
    end

    return @leaders
  end
  
  def split_name full_name
    names = {}
    split_names = full_name.split(" ")
    if split_names.length == 3
      names[:first] = split_names[0]
      names[:last] = "#{split_names[1]} #{split_names[2]}" #jr., sr., III, etc
    else
      names[:first] = split_names[0]
      names[:last] = split_names[1]
    end
    
    names
  end
  
  def update_db(scraped_name="- -", current_score="E", through="", pos="")
   puts "scraped name: #{scraped_name}"
   puts current_score
     
   first_name = self.split_name(scraped_name)[:first]
   last_name = self.split_name(scraped_name)[:last]
   
   puts "first name: #{first_name}"
   puts "last name: #{last_name}"
   
   if current_score == "E"
     current_score = 0
   else
     current_score = current_score.to_i
   end
   puts "current_score: #{current_score}"
   
   #dbh = Mysql.real_connect("127.0.0.1", "root", "", "eyeon2_local_20080410")
   dbh = Mysql.real_connect("65.36.177.230", "eyeon2", "pgachamp", "eyeon2") 
   if first_name != nil || last_name != nil || first_name != "WD"
     fn = dbh.escape_string(first_name)
     ln = dbh.escape_string(last_name)
     puts "#{through} --- through.length: #{through.length}"
     if through != nil
     if through.length <= 4
       tru = through 
     else
       tru = "-"
     end
     end
     str = "SELECT CurrentScoreRelPar, GolferFirstName, GolferLastName 
      FROM tgolfer WHERE GolferFirstName = '#{fn}' 
      AND GolferLastName = '#{ln}'"
     # puts str
     q_preupdate = dbh.query("SELECT CurrentScoreRelPar, GolferFirstName, GolferLastName 
       FROM tgolfer WHERE GolferFirstName = '#{fn}' 
       AND GolferLastName = '#{ln}'")
     if q_preupdate.num_rows == 1
       q_update = dbh.query("UPDATE tgolfer SET CurrentScoreRelPar = #{current_score}, 
       thru = '#{tru}', position = '#{pos}'
       WHERE GolferFirstName = '#{fn}' 
       AND GolferLastName = '#{ln}'")
       q_getupdate = dbh.query("SELECT CurrentScoreRelPar, GolferFirstName, GolferLastName 
       FROM tgolfer WHERE GolferFirstName = '#{fn}' 
       AND GolferLastName = '#{ln}'")
       # q_getupdate.each do |row|
       #  printf "%s, %s, %s\n", row[0], row[1], row[2]
       # end
       q_getupdate.free
       q_preupdate.free
     else
       puts "************* no match with : #{scraped_name} ****************" # therefore inserting new..."
       # q_insert = dbh.query("INSERT INTO tgolfer (GolferFirstName, 
       #   GolferLastName, CurrentScoreRelPar, DegsofWallyVal, 
       #   GolferImage, active, madecut, thru) 
       #   VALUES ('#{first_name}', '#{last_name}', 0, 2, 'qualifier.gif', 1, 0, 0)")
     end
   end
   dbh.close if dbh #disconnect
  end
  
  
  def update_all_leaders leaders
    leaders.each do |player|
      update_db(player[:player], player[:to_par], player[:thru])
    end
  end
  
  def to_screen leader_index
    if leader_index < 1
      @leaders.each do |player|
        player.each {|k, v| puts "#{k} : #{v}" }
      end
    else
      @leaders[leader_index].each{ |k, v| puts "#{k} : #{v}" }
    end
    
  end 
  
end






