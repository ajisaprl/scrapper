require 'telegram/bot'
require 'pry'
require './scrapper'

token = '2007354675:AAGwCTKJjtzwpjbkz6Z8buXYjQk5_CvjHlQ'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      question = 'Please input product keyword'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. #{question}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
		end
		# product_keyword = message.text
		# bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "YOOO")
  end
end
