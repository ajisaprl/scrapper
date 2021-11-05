require 'telegram/bot'
require 'pry'
require './scrapper'

@token = '2007354675:AAGwCTKJjtzwpjbkz6Z8buXYjQk5_CvjHlQ'
@keyword = ''
@marketplace = ''

def get_keyword
	Telegram::Bot::Client.run(@token) do |bot|
		bot.listen do |message|
			question = 'Please input product keyword with format: "/key product_keyword"'
			bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. #{question}")
			break
		end
	end
end

def select_marketplace
	Telegram::Bot::Client.run(@token) do |bot|
		bot.listen do |message|
				kb = [
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Bukalapak'),
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Tokopedia'),
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Shopee'),
				]
				markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
				bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: 'Choose Marketplace:', reply_markup: markup)
				break
		end
	end
end

Telegram::Bot::Client.run(@token) do |bot|
	bot.listen do |message|
		case
		when message.text.eql?('/start')
			get_keyword
		when message.text.include?('/key')
			@keyword = message.text.gsub('/key', '').lstrip
			select_marketplace
		when ['Bukalapak', 'Tokopedia', 'Shopee'].any? { |text| text.include? message.text }
			@marketplace = message.text
			Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
		end
		unless @marketplace.empty? || @keyword.empty?
			Scrapper.scrapper(@keyword, @marketplace)
			bot.api.send_document(chat_id: message.chat.id, reply_to_message_id: message.message_id, document: Faraday::UploadIO.new('./data.csv', 'csv'))
			@keyword = ''
			@marketplace = ''
		end
	end
end
