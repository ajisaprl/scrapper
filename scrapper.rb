require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'
require 'csv'

def scrapper
	page = 1
	last_page = 5
	csv = CSV.open("data.csv", "a+")
	csv << ["Product Name", "Price", "Location", "URL"]
	while page <= last_page
		url = "https://www.bukalapak.com/products?page=#{page}&search%5Bkeywords%5D=kemeja"
		doc = Nokogiri::HTML(open(url))
		puts "Scrapping page #{page}..."
		product_cards = doc.search('div.product-card')
		product_cards.each do |product_card|
			product = {
				productName: product_card.css('a.product__name').text,
				productPrice: product_card.css('div.product-price')[0].attributes["data-reduced-price"].text,
				storeLocation: product_card.css('div.user-city').text,
				url: "https://www.bukalapak.com" + product_card.search('a')[0].attributes["href"].value
			}
			csv << ["#{product[:productName]}", "#{product[:productPrice]}","#{product[:storeLocation]}","#{product[:url]}"]
		end
		page += 1
	end
	puts "Scrapped data in data.csv"
end

scrapper
