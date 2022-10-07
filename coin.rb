require 'dotenv/load'
require 'yaml'
require 'discordrb'

COIN_TIMEOUT = 15
SCOREBOARD = './scoreboard.yml'
coin_state_active = false

bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN']

def get_seconds_to_midnight(time)
  t2 = Time.new(time.year, time.month, time.day + 1)
  return t2 - time
end

def get_random_duration(time)
  max = get_seconds_to_midnight(time)
  return rand(0..max)
end

def load_scoreboard()
  YAML::load_file(SCOREBOARD) || {}
end

def get_coin_count(scoreboard, user)
  scoreboard[user] || 0
end

def increment_coin(scoreboard, user)
  coins = get_coin_count(scoreboard, user) + 1
  scoreboard[user] = coins

  File.write(SCOREBOARD, scoreboard.to_yaml)
end

def plural(string, count)
  "#{count} #{string}#{count > 1 ? 's' : ''}"
end

bot.message(with_text: 'GET COIN' ) do |event|
  # update score
  if coin_state_active
    scoreboard = load_scoreboard()
    increment_coin(scoreboard, event.author.id)

    coin_state_active = false

    coins = get_coin_count(scoreboard, event.author.id)
    event.respond "Nice catch, #{event.author.name}! You have #{plural('coin', coins)} now!"
  else
    event.respond "No coins for you, #{event.author.name}!"
  end
end

bot.message(with_text: '/coins') do |event|
  coins = get_coin_count(load_scoreboard(), event.author.id)
  event.respond "#{event.author.name}, you have #{plural('coin', coins)}!"
end

bot.run(true)

loop do 
  # sleep until random time from now to midnight
  # sleep(get_random_duration(Time.now))

  # activate coin state
  coin_state_active = true
  # send coin GIF
  bot.send_file(ENV['BOT_CHANNEL'], File.open('./coin.gif', 'r'))

  # sleep until midnight to reset cycle
  sleep(get_seconds_to_midnight(Time.now))
end




bot.join()
