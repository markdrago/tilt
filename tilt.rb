#!/usr/bin/ruby

require 'sqlite3'

class Player
  attr_reader :name
  attr_reader :scores

  def initialize(name)
    @name = name
    @scores = Array.new
  end

  def addscore(score)
    total = get_total_score
    @scores.push(score - total)
  end

  def produce_score_report()
    printf "#{@name}"
    @scores.each { |score|
      printf "\t#{score}"
    }
    printf "\t#{get_total_score}\n"
  end

  def get_total_score()
    total = 0
    @scores.each { |score|
      total += score
    }

    return total
  end
end

class Game
  attr_reader :num_players
  attr_writer :num_players

  def initialize()
    @players = Array.new
  end

  def play_game()
    prompt_for_num_players()
    prompt_for_player_names()
    prompt_for_scores()
    print_full_score_report()
    store_scores_in_db()
  end

  def prompt_for_num_players()
    print "Enter number of players: "
    @num_players = gets.to_i
    printf "\n"
  end

  def prompt_for_player_names()
    @num_players.times { |i|
      print "Enter name for player ##{i+1}: "
      name = gets
      name.strip!
      @players[i] = Player.new(name)
    }
  end

  def prompt_for_scores()
    printf "\n"
    5.times { |roundnum|
      @players.each { |player|
        print "Enter #{player.name}'s score after round ##{roundnum + 1}: "
        scorestr = gets
        score = scorestr.strip!.to_i
        player.addscore(score)
      }
    }
  end

  def print_full_score_report()
    #print header and then the score report for each player
    printf "\nPlayer"
    5.times { |i|
      printf "\tRnd ##{i + 1}"
    }
    printf "\tTotal\n"
    @players.each { |player|
      player.produce_score_report()
    }
  end

  def store_scores_in_db()
    db = SQLite3::Database.new("tilt.db")
    db.execute("insert into session values (NULL, #{@num_players}, datetime('now'))")
    session_id = db.last_insert_row_id()

    @players.each { |player|
      total_score = player.get_total_score()
      db.execute("insert into game values (NULL, #{session_id}, '#{player.name}', #{total_score})")
      game_id = db.last_insert_row_id()

      round_num = 1
      player.scores.each { |score|
        db.execute("insert into round values (NULL, #{game_id}, #{round_num}, #{score})")
        round_num = round_num + 1
      }
    }
    db.close()
  end
end
  
class Stats

  def initialize()
    @db = SQLite3::Database.new("tilt.db")    
  end

  def produce_overall_stats()
    produce_overall_high_scores()
    produce_overall_avg_scores()
    produce_overall_low_scores()
  end

  def produce_individual_stats()
    player_name = get_player_name()
    produce_individual_high_scores(player_name)
    produce_individual_average_score(player_name)
    produce_individual_low_scores(player_name)
  end

  def produce_overall_high_scores()
    num = 1
    printf "\n\nHigh Scores:\n"
    @db.execute("select player_name, total_score from game order by total_score desc limit 10") { |highscore|
      printf "#{num}. #{highscore[0]} -- #{highscore[1]}\n"
      num = num + 1
    }
  end

  def produce_overall_avg_scores()
    num = 1
    printf "\nHigh Averages:\n"
    @db.execute("select player_name, avg(total_score) from game group by player_name order by avg(total_score) desc") { |avgscore|
      printf "#{num}. #{avgscore[0]} -- #{avgscore[1]}\n"
      num = num + 1
    }
  end

  def produce_overall_low_scores()
    num = 1
    printf "\nLow Scores:\n"
    @db.execute("select player_name, total_score from game order by total_score asc limit 5") { |lowscore|
      printf "#{num}. #{lowscore[0]} -- #{lowscore[1]}\n"
      num = num + 1
    }
  end

  def get_player_name()
    players = []
    printf "\n\nChoose Player:\n"
    @db.execute("select distinct player_name from game order by player_name") { |name|
      players.push(name[0])
    }

    players.each_index { |i|
      printf "#{i+1}. #{players[i]}\n"
    }

    printf "\nEnter Player Number: "
    playernum_str = gets
    playernum = playernum_str.strip!.to_i - 1

    return players[playernum]
  end

  def produce_individual_high_scores(player_name)
    printf "\n\n#{player_name}'s High Scores:\n"
    num = 1
    @db.execute("select total_score from game where player_name='#{player_name}' order by total_score desc limit 10") { |highscore|
      printf "#{num}. #{highscore[0]}\n"
      num = num + 1
    }
  end

  def produce_individual_average_score(player_name)
    printf "\n#{player_name}'s Average Score: "
    @db.execute("select avg(total_score) from game where player_name='#{player_name}'") { |avgscore|
      avg = avgscore[0].to_i
      printf "#{avg}\n"
    }
  end

  def produce_individual_low_scores(player_name)
    printf "\n#{player_name}'s Low Scores:\n"
    num = 1
    @db.execute("select total_score from game where player_name='#{player_name}' order by total_score asc limit 5") { |lowscore|
      printf "#{num}. #{lowscore[0]}\n"
      num = num + 1
    }
  end
end

class Tilt

  def prompt_menu()
    printf "________________________________\n"
    printf "TILT v0.1\n"
    printf "  1. Play a game\n"
    printf "  2. Print Overall Statistics\n"
    printf "  3. Print Personal Statistics\n"
    printf "  4. Quit\n"
    printf "Please make a choice: "
    
    choice = gets.to_i
    
    case choice
    when 1
      game = Game.new()
      game.play_game()
    when 2
      stats = Stats.new()
      stats.produce_overall_stats()
    when 3
      stats = Stats.new()
      stats.produce_individual_stats()
    when 4
      exit
    end

    printf "\n";
    prompt_menu()

  end
end

tilt = Tilt.new()
tilt.prompt_menu()
