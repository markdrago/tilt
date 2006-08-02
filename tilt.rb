#!/usr/bin/ruby -w

class Player
  attr_reader :name

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

  def initialize(name)
    @name = name
    @scores = Array.new
  end
end

print "Enter number of players: "
num_players = gets.to_i
printf "\n"

players = Array.new
num_players.times { |i|
  print "Enter name for player ##{i+1}: "
  name = gets
  name.strip!
  players[i] = Player.new(name)
}

printf "\n"
5.times { |roundnum|
  players.each { |player|
    print "Enter #{player.name}'s score after round ##{roundnum + 1}: "
    scorestr = gets
    score = scorestr.strip!.to_i
    player.addscore(score)
  }
}

#print header and then the score report for each player
printf "\nPlayer"
5.times { |i|
  printf "\tRnd ##{i + 1}"
}
printf "\tTotal\n"
players.each { |player|
  player.produce_score_report()
}
