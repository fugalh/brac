# Play the game of roshambo (rock-paper-scissors)
# Copyright (C) 2004 Hans Fugal
# Distributed under the same license as rbot itself
require 'yaml'
require 'time'
class RoshamboPlugin < Plugin
  def initialize
    super 
    @scoreboard = {}
  end
  
  def help(plugin, topic="")
    "roshambo <rock|paper|scissors> => play roshambo"
  end

  def privmsg(m)
    # simultaneity
    choice = choose

    # init scoreboard
    if (not @scoreboard.has_key?(m.sourcenick) or (Time.now - @scoreboard[m.sourcenick]['timestamp']) > 3600)
      @scoreboard[m.sourcenick] = {'me'=>0,'you'=>0,'ties'=>0,'timestamp'=>Time.now}
    end
    case m.params
    when /rock/i
      rps = 'rock'
    when /paper/i
      rps = 'paper'
    when /scissors/i
      rps = 'scissors'
    when 'score'
      sb = @scoreboard[m.sourcenick]
      m.reply "me: #{sb['me']}, #{m.sourcenick}: #{sb['you']}, ties: #{sb['ties']}"
      return
    when 'barf'
      m.reply m.to_s
      m.reply @scoreboard.to_yaml
      return
    else
      m.reply "incorrect usage: " + help(m.plugin)
      return
    end

    s = score(choice,m.params)
    @scoreboard[m.sourcenick]['timestamp'] = Time.now
    myscore=@scoreboard[m.sourcenick]['me']
    yourscore=@scoreboard[m.sourcenick]['you']
    case s
    when 1
      yourscore=@scoreboard[m.sourcenick]['you'] += 1
      m.reply "#{choice}. You win."
      @bot.action m.channel, "bares his arm and cringes" if rand < 0.7
    when 0
      @scoreboard[m.sourcenick]['ties'] += 1
      m.reply "#{choice}. We tie."
    when -1
      myscore=@scoreboard[m.sourcenick]['me'] += 1
      m.reply "#{choice}! I win!"
      if rand < 0.5
	if rand < 0.5
	  m.reply "~lart #{m.sourcenick}"
	else
	  @bot.action m.channel,"licks his fingers" if rand < 0.2
	  @bot.action m.channel,"slaps #{m.sourcenick}'s forearm"
	end
      end
    end
  end
      
  def choose
    ['rock','paper','scissors'][rand(3)]
  end
  def score(a,b)
    beats = {'rock'=>'scissors', 'paper'=>'rock', 'scissors'=>'paper'}
    return -1 if beats[a] == b
    return 1 if beats[b] == a
    return 0
  end
end
plugin = RoshamboPlugin.new
plugin.register("roshambo")
plugin = RoshamboPlugin.new
plugin.register("rps")
