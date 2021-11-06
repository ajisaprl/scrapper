#!/usr/bin/ruby

require 'nokogiri'
require 'httparty'
require 'open-uri'
require 'csv'
require 'rest-client'
require 'pry'
require 'json'
require 'net/http'
require 'uri'
require './support/tokopedia_support'
require 'telegram/bot'

class Scrapper
	def self.generate_csv
		previous_user = nil
		Telegram::Bot::Client.run($token) do |bot|
			bot.listen do |message|
				users = []
				users << message.chat.username
				users_csv = CSV.open("users.csv", 'a+')
				users_csv << users.uniq
				@chat_id = message.from.id
				@csv = CSV.open("data#{@chat_id}.csv", 'w+')
				@csv << ['Product Name', 'Price', 'Location', 'URL']
				break
			end
		end
	end

	def self.scrapper(product_keyword, marketplace)
		generate_csv
		sleep 3
		@csv = CSV.open("data#{@chat_id}.csv", 'w+')
		sleep 3
		retries = 0
		begin
			case marketplace
			when 'Bukalapak'
				@csv << ['Product Name', 'Price', 'Location', 'URL']
				access_token = RestClient.post 'https://www.bukalapak.com/westeros_auth_proxies', "{\"application_id\":1,\"authenticity_token\":\"\"}"			
				response = RestClient.get "https://api.bukalapak.com/multistrategy-products?keywords=#{product_keyword}&limit=50&offset=0&facet=true&page=1&access_token=#{JSON.parse(access_token)['access_token']}"
				n = 0
				while n < JSON.parse(response)['data'].count 
					product = {
						productName: JSON.parse(response)['data'][n]['name'],
						productPrice: JSON.parse(response)['data'][n]['price'],
						storeLocation: JSON.parse(response)['data'][n]['store']['address']['city'],
						url: JSON.parse(response)['data'][n]['url']
					}
					n += 1
					p "STATUS: #{response.status}"
					p "BODY: #{response.body}"
					@csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
				end
			when 'Tokopedia'
				n = 0
				response = TokopediaSupport.curl_command(product_keyword)
				@csv << ['Product Name', 'Price', 'Location', 'URL']
				sleep 3
				while n < JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'].count
					product = {
						productName: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['name'],
						productPrice: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['price'],
						storeLocation: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['shop']['city'],
						url: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['url']
					}
					n += 1
					@csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
				end
			when 'Shopee'
				n = 0
				retries = 0
				begin
					response = RestClient.get "https://shopee.co.id/api/v4/search/search_items?by=relevancy&keyword=#{product_keyword}&limit=60&newest=0&order=desc&page_type=search&scenario=PAGE_GLOBAL_SEARCH&version=2"
					@csv << ['Product Name', 'Price', 'Location', 'URL']
					sleep 3
					JSON.parse(response)['items'].count
				rescue NoMethodError => e
					p 'failed at COUNT'
					retry if (retries += 1) < 5
					raise e.message if retries == 5
				end
				while n < JSON.parse(response)['items'].count 
					product = {
						productName: JSON.parse(response)['items'][n]['item_basic']['name'],
						productPrice: JSON.parse(response)['items'][n]['item_basic']['price']/100000,
						storeLocation: JSON.parse(response)['items'][n]['item_basic']['shop_location'],
						url: 'No URL'
					}
					n += 1
					@csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
				end
				if CSV.open("data#{@chat_id}.csv").count == 1
					n = 0
					while n < JSON.parse(response)['items'].count 
						product = {
							productName: JSON.parse(response)['items'][n]['item_basic']['name'],
							productPrice: JSON.parse(response)['items'][n]['item_basic']['price']/100000,
							storeLocation: JSON.parse(response)['items'][n]['item_basic']['shop_location'],
							url: 'No URL'
						}
						n += 1
						@csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
					end
				end
			else
				puts "Not available yet"
			end
		rescue RestClient::Forbidden => e
			retry if (retries += 1) < 5
			Telegram::Bot::Client.run($token) do |bot|
				bot.listen do |message|
					bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: 'Forbidden response from API. Retrying (3x)...')
					break
				end
			end
		end
		puts "Scrapped data in data.csv"
	end
end
