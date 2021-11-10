require 'telegram/bot'
require 'pry'
require './scrapper'

$token = '2007354675:AAGwCTKJjtzwpjbkz6Z8buXYjQk5_CvjHlQ'
@keyword = ''
@marketplace = ''

def get_keyword
	Telegram::Bot::Client.run($token) do |bot|
		bot.listen do |message|
			question = 'Please input product keyword with format: `/key Product Name`'
			bot.api.send_message(chat_id: message.chat.id, text: "#{question}", parse_mode: 'markdown')
			break
		end
	end
end

def select_marketplace
	Telegram::Bot::Client.run($token) do |bot|
		bot.listen do |message|
				kb = [
					# Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Bukalapak'),
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Tokopedia'),
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Shopee'),
					Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Tanihub'),
				]
				markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
				bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: 'Choose Marketplace:', reply_markup: markup)
				break
		end
	end
end

Telegram::Bot::Client.run($token) do |bot|
	bot.listen do |message|
		case message
		when Telegram::Bot::Types::Message
			case
			when message.text.eql?('/start')
				get_keyword
			when message.text.include?('/key')
				@keyword = message.text.gsub('/key', '').lstrip
				select_marketplace
			when ['Tokopedia', 'Shopee', 'Tanihub'].any? { |text| text.include? message.text }
				@marketplace = message.text
				Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
			end
			unless @marketplace.empty? || @keyword.empty?
				Scrapper.scrapper(@keyword, @marketplace)
				bot.api.send_chat_action(chat_id: message.chat.id, action: 'upload_document')
				retries = 0
				begin
					bot.api.send_document(chat_id: message.chat.id, reply_to_message_id: message.message_id, document: Faraday::UploadIO.new("./data#{message.from.id}.csv", 'csv'))
				rescue Telegram::Bot::Exceptions::ResponseError => e
					p 'failed at empty file'
					Scrapper.scrapper(@keyword, @marketplace)
					retries += 1
					if retries < 3
						retry
					else
						p 'writing headers'
						@csv = CSV.open("data#{message.from.id}.csv", 'a+')
						@csv << ['Product Name', 'Price', 'Location', 'URL']
						retry
					end
				end
				@keyword = ''
				@marketplace = ''
			end
		when Telegram::Bot::Types::ChatMemberUpdated
			p 'KENANICH'
			next
		end
	end
end
