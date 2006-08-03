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
      db.execute("insert into game values (NULL, #{session_id}, '#{player.name}')")
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
  
class Tilt

  def prompt_menu()
    printf "TILT v0.1\n"
    printf "\n"
    printf "  1. Play a game\n"
    printf "  2. Print Overall Statistics\n"
    printf "  3. Print Personal Statistics\n"
    printf "  4. Quit\n"
    printf "\n"
    printf "Please make a choice: "
    
    choice = gets.to_i
    
    case choice
    when 1
      game = Game.new()
      game.play_game()
    when 4
      exit
    else
      prompt_menu()
    end
  end
end

tilt = Tilt.new()
tilt.prompt_menu()
