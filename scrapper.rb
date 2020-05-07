require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'

def scrapper
	page = 1
	last_page = 5

	while page <= last_page
		url = "https://www.bukalapak.com/products?page=#{page}&search%5Bkeywords%5D=kemeja"
		doc = Nokogiri::HTML(open(url))
		puts "Page: #{page}"
		puts ''
		product_listings = doc.search('div.product-card')
		product_listings.each do |product_listing|
			product = {
				productName: product_listing.css('a.product__name').text,
				productPrice: product_listing.css('div.product-price')[0].attributes["data-reduced-price"].text,
				storeLocation: product_listing.css('div.user-city').text,
				url: "https://www.bukalapak.com" + product_listing.search('a')[0].attributes["href"].value
			}
			puts "Product Name: #{product[:productName]}"
			puts "Product Price: #{product[:productPrice]}"
			puts "Store Location: #{product[:storeLocation]}"
			puts "Product URL: #{product[:url]}"
			puts '#########################'
		end
		page += 1
	end
end

scrapper
