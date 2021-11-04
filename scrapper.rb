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

def scrapper
	csv = CSV.open("data.csv", "a+")

	# TO DO: Implement clean up CSV
	puts "Product Keyword: "
	product_keyword = gets.chomp
	puts "Choose Marketplace: "
	puts "[1] Bukalapak"
	puts "[2] Tokopedia"
	marketplace = gets.chomp
	puts "Scrapping begin"
	case marketplace
	when "1"
		access_token = RestClient.post "https://www.bukalapak.com/westeros_auth_proxies", "{\"application_id\":1,\"authenticity_token\":\"\"}"			
		csv << ["Product Name", "Price", "Location", "URL"]
		response = RestClient.get "https://api.bukalapak.com/multistrategy-products?keywords=#{product_keyword}&limit=50&offset=0&facet=true&page=1&access_token=#{JSON.parse(access_token)['access_token']}"
		n = 0
		while n != JSON.parse(response)['meta']['per_page'] 
			product = {
				productName: JSON.parse(response)['data'][n]['name'],
				productPrice: JSON.parse(response)['data'][n]['price'],
				storeLocation: JSON.parse(response)['data'][n]['store']['address']['city'],
				url: JSON.parse(response)['data'][n]['url']
			}
			n += 1
			csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
		end
	when "2"
		csv << ["Product Name", "Price", "Location", "URL"]
		n = 0
		count = 1
		while n < count
			response = TokopediaSupport.curl_command(product_keyword)
			product = {
				productName: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['name'],
				productPrice: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['price'],
				storeLocation: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['shop']['city'],
				url: JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'][n]['url']
			}
			n += 1
			count = JSON.parse(response.body)[1]['data']['ace_search_product_v4']['data']['products'].count
			csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
		end
	else
		puts "Not available yet"
	end
	puts "Scrapped data in data.csv"
end

scrapper
