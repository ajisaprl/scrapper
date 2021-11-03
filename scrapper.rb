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

def scrapper
	csv = CSV.open("data.csv", "a+")
	# csv = CSV.parse(File.read("data.csv"), headers: true)

	# puts "Delete previous data? [Y/N]"
	# action = gets.chomp
	# if action.downcase.eql? 'y'
	# 	table = CSV.parse(File.read("data.csv"), headers: true)
	# 	updated = table.delete("Product Name", "Price", "Location", "URL")
	# end

	puts "Choose Marketplace: "
	puts "[1] Bukalapak"
	puts "[2] Tokopedia"
	marketplace = gets.chomp
	puts "Scrapping begin"
	case marketplace
	when "1"
		csv << ["Product Name", "Price", "Location", "URL"]
		response = RestClient.get "https://api.bukalapak.com/multistrategy-products?keywords=headset&limit=50&offset=0&facet=true&page=1&access_token=YaCUZBU3AJZF5W920JG4Nm89HYE9BCafQ5cCP5QHU1f4mA"
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
			uri = URI.parse("https://gql.tokopedia.com/")
			request = Net::HTTP::Post.new(uri)
			request.content_type = "application/json"
			request["Accept"] = "*/*"
			request["Accept-Language"] = "en-US,en;q=0.9"
			request["Authority"] = "gql.tokopedia.com"
			request["Cache-Control"] = "no-cache"
			request["Cookie"] = "_UUID_NONLOGIN_=4576dae78a5cd70a7e501640d4a7bfb2; _UUID_NONLOGIN_.sig=1weOhPXhNgScDRdq7NF6yz16tHU; DID=e5b210bb6e0e60ae8e6f4ec5ac4e707da75e812b1946eeb0d34ffd29b3a3f30ac52520105c9e006740bf86d11ed09e6c; DID_JS=ZTViMjEwYmI2ZTBlNjBhZThlNmY0ZWM1YWM0ZTcwN2RhNzVlODEyYjE5NDZlZWIwZDM0ZmZkMjliM2EzZjMwYWM1MjUyMDEwNWM5ZTAwNjc0MGJmODZkMTFlZDA5ZTZj47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=; __auc=a196cba3175fa00db9073e4cea2; _jx=d5455aa0-2e47-11eb-ba48-fd13b1d0849d; _hjid=5a91d637-c5fa-494b-bf9d-f4e5b449f227; hfv_banner=true; _gcl_aw=GCL.1634919357.CjwKCAjwwsmLBhACEiwANq-tXLZWuXu0tioHCB4XMiZwxzPYK5ysdTJFv64UdkdgTzq4TFJULTpqTBoCRK8QAvD_BwE; _gcl_dc=GCL.1634919357.CjwKCAjwwsmLBhACEiwANq-tXLZWuXu0tioHCB4XMiZwxzPYK5ysdTJFv64UdkdgTzq4TFJULTpqTBoCRK8QAvD_BwE; _gac_UA-126956641-6=1.1634919357.CjwKCAjwwsmLBhACEiwANq-tXLZWuXu0tioHCB4XMiZwxzPYK5ysdTJFv64UdkdgTzq4TFJULTpqTBoCRK8QAvD_BwE; _gac_UA-9801603-1=1.1634919359.CjwKCAjwwsmLBhACEiwANq-tXLZWuXu0tioHCB4XMiZwxzPYK5ysdTJFv64UdkdgTzq4TFJULTpqTBoCRK8QAvD_BwE; l=1; _SID_Tokopedia_=Jkvhmnu-tea7gGUrYmuF6xyLtKccAQLdrujFI3pzUVyMtUERuwXT_C__aherOWq_scFsxta7Aqu0V6hRasDQLvJ_lGbG-b_2gCz2SVZQ7ASsfSBAFlM0UDTrkQ8WEueF; _gcl_au=1.1.1176443983.1635863521; bm_sz=69E10B8B2D7CBCDF244CFE61E7C85C8C~YAAQ519idhkRK+R8AQAAyfdr5g3rnYe+B8mjVAO5/puv6VBNgOWvTBLarJ6ibHnYjbLjoDQrrZEVOCYKNe1C4VqDJwMkaChLNhMX1nqj5dwBuenTkPrUOuuUNMdxsczyUsL6SFJUFVNAMVdWRZHGdWBjcTVRMU6nU8MYZNhwL97qFlk1SCa+bbMxID+qNdBN0v5ZoWFPdUym0yhAimqe5Qua35314eEkdcOFLa2J+Uk9TDLbBq8AJAzZIbf5o6hH1NZXA1jlFJdcN9JvbLF5sCskn/jeGunFIhYkPi9fWFqryf95TX4=~3551792~3486786; ak_bmsc=EBE2F62C5E27860697C7E54FF064DFA2~000000000000000000000000000000~YAAQ519idigRK+R8AQAAEvtr5g3VLJaIncMijXxfu91yV6vHnCjsLJJjNBltnWRB3BvMeBqT+EwEsMiTUNo1Rx23bXySj/Iqnxc1pZdzZYCEV8K0TyZ0ZMUTs6vxf9HRREHcWYGMyge++jYMd1qADMVeO+QuCjewu9pvi8kfQuHPJR8m8rBahttgmLlSyeR1s27dvqsUjNJ7sqd7ivAo3rOdA6GdprXmJqot+d8eHMHOWC8W/YexHPrKzTuVF49oFEkuXwd4kVkPGlm04dogg2ZvZsNprvRBcfnVRLiWSBeWPEIWSKF10mNTtEGyeIaSpWKEITYvJQ+shIpMK+UeGdNM2+01QEWKttfoteOLtIVL8m1Jz6Kra0yU6D8KjclnJgYvV8s8niEw0zC5Mw==; _gid=GA1.2.35157305.1635953409; __asc=219e2eaf17ce66c0f1e6ee02699; TOPATK=G9Ycx5t1TzK6KDeSGbOtDg; TOPRTK=J4UBJzFRTAmDaRiwebMRjQ; tuid=3078630; _abck=E198C17DBE308D4D3163A4F658225D2C~0~YAAQ519idncRK+R8AQAAIxVs5gZ0zhjnIZJrZJnPVk5zsQYpbNguIV9wHVUC/XaxeyQGgsYiY3NvmpFcLYLwNNkotP6LfcRCMQxdHqvaFdz3qNli17lTwNl3/blr6J9CKWzl4uZUeUQ2qSwvcAvNMiU/CkY9HeJpGpi9j6o4Hq/hB1L+MNbeBRBHIncsK9QzMaUHNTQdKDViwynSzL0UQO5Pfp6wI4iTBrfHxN1haWF5yJN9EkJs8uLMuscEKZO3foAGIRiXo6kkeFu1kfuJA3iHwaDMYLbCWCilsoaGkzQf5ZhsjKJoJDpYzuA3bcLZSoquA5745g/1Xg1PaYX1BHDFwvw/FIxZG3A6693PF3QIwnR/B/hbjlSp6HiQ2JnPVvYvLOaJELS2FKNCD6mVBnjptSQklsWmkiKE~-1~-1~-1; g_yolo_production=1; bm_mi=89B614D49A05CDBAA1ECE7DFCF1D0553~9ZLrFtzv4d3pjZMJ5CwTieJTWjjXIULmo5ENUMDrZhPyVBq3gB8ZWb1XFbv88XV6gTLDfDXxbX6MiPRJGWAP+j7iJc+myoq6zQK4hNzXmirQOXG4ix5nDVF2J3w/wV2yf9qWC+az5XeMxdHciZTzQf6726CEhB2mcUa9Sy3/03UQDcVZomPGpw+zTumBKYPnhUkv7RWm4urf9K0p+gGEHYdCFTN6IAROUWFvwrDwCLxgu/D5AbB7Wj4lMVkDZbgLczgKe2AB2dNrpK3zRJ9EgQ==; _ga=GA1.2.1376188814.1606217157; bm_sv=1D578788B3021C4CDC44A620583E0CA4~rTrKdMhJnMxbDHkPDwNWSpZ+sRuXKnskcw0evKrN36947Lo70nXG40RZ+3cS3NUnuuzDC6YpSVbScMJhp52yi6Asg8cnxA3zlpMKNmGT3E4gDqpym9xmPzlvW5RKFuXET6JGE77Bv0aaQCMv4g9BKXt38mrVPWDDVgZAvV2cG0c=; _jxs=1635953428-d5455aa0-2e47-11eb-ba48-fd13b1d0849d; cto_bundle=6cWuD19ieHR6JTJCUVVPcHJaeG5GeWpDNVZZSThGakxtNXlYWFlNMGx5Y0lONGc3bmNmQ2Vycm1LUm5Ka2o5QUlwdDJYaHRKcjhkUWppSWNCWmFaNnZFWFBzJTJGUnBvMSUyRnQlMkZaaU9UVExKOFJxb1o0ckFMN1N4TVF3SEZwQlNXQ3UlMkJjeVlBNnMzRSUyQm95dDFwc2NIT2djVDBMTjlFS3clM0QlM0Q; _dc_gtm_UA-126956641-6=1; _dc_gtm_UA-9801603-1=1; _gat_UA-9801603-1=1; _ga_70947XW48P=GS1.1.1635953408.29.1.1635953520.12"
			request["Origin"] = "https://www.tokopedia.com"
			request["Postman-Token"] = "7ba5fe85-ac1a-905e-1b92-5e1d49356793"
			request["Referer"] = "https://www.tokopedia.com/search?st=product&q=kemeja&navsource=home"
			request["Sec-Ch-Ua"] = "\\\"Google Chrome\\\";v=\\\"95\\\", \\\"Chromium\\\";v=\\\"95\\\", \\\";Not A Brand\\\";v=\\\"99\\\""
			request["Sec-Ch-Ua-Mobile"] = "?0"
			request["Sec-Ch-Ua-Platform"] = "\\\"macOS\\\""
			request["Sec-Fetch-Dest"] = "empty"
			request["Sec-Fetch-Mode"] = "cors"
			request["Sec-Fetch-Site"] = "same-site"
			request["Tkpd-Userid"] = "0"
			request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36"
			request["X-Device"] = "desktop-0.0"
			request["X-Source"] = "tokopedia-lite"
			request["X-Tkpd-Lite-Service"] = "zeus"
			request["X-Version"] = "9152c61"
			request.body = JSON.dump([
				{
					"operationName" => "FilterSortProductQuery",
					"variables" => {
						"params" => "navsource=home&q=kemeja&source=search_product&st=product"
					},
					"query" => "query FilterSortProductQuery($params: String!) {
				filter_sort_product(params: $params) {
					data {
						filter {
							title
							template_name
							search {
								searchable
								placeholder
								__typename
							}
							options {
								name
								Description
								key
								icon
								value
								inputType
								totalData
								valMax
								valMin
								hexColor
								child {
									key
									value
									name
									icon
									inputType
									totalData
									child {
										key
										value
										name
										icon
										inputType
										totalData
										child {
											key
											value
											name
											icon
											inputType
											totalData
											__typename
										}
										__typename
									}
									isPopular
									__typename
								}
								isPopular
								isNew
								__typename
							}
							__typename
						}
						sort {
							name
							key
							value
							inputType
							applyFilter
							__typename
						}
						__typename
					}
					__typename
				}
			}
			"
				},
				{
					"operationName" => "SearchProductQueryV4",
					"variables" => {
						"params" => "device=desktop&navsource=home&ob=23&page=1&q=kemeja&related=true&rows=60&safe_search=false&scheme=https&shipping=&source=search&st=product&start=0&topads_bucket=true&unique_id=4576dae78a5cd70a7e501640d4a7bfb2&user_addressId=&user_cityId=176&user_districtId=2274&user_id=&user_lat=&user_long=&user_postCode=&variants="
					},
					"query" => "query SearchProductQueryV4($params: String!) {
				ace_search_product_v4(params: $params) {
					header {
						totalData
						totalDataText
						processTime
						responseCode
						errorMessage
						additionalParams
						keywordProcess
						__typename
					}
					data {
						isQuerySafe
						ticker {
							text
							query
							typeId
							__typename
						}
						redirection {
							redirectUrl
							departmentId
							__typename
						}
						related {
							relatedKeyword
							otherRelated {
								keyword
								url
								product {
									id
									name
									price
									imageUrl
									rating
									countReview
									url
									priceStr
									wishlist
									shop {
										city
										isOfficial
										isPowerBadge
										__typename
									}
									ads {
										adsId: id
										productClickUrl
										productWishlistUrl
										shopClickUrl
										productViewUrl
										__typename
									}
									badges {
										title
										imageUrl
										show
										__typename
									}
									ratingAverage
									labelGroups {
										position
										type
										title
										url
										__typename
									}
									__typename
								}
								__typename
							}
							__typename
						}
						suggestion {
							currentKeyword
							suggestion
							suggestionCount
							instead
							insteadCount
							query
							text
							__typename
						}
						products {
							id
							name
							ads {
								adsId: id
								productClickUrl
								productWishlistUrl
								productViewUrl
								__typename
							}
							badges {
								title
								imageUrl
								show
								__typename
							}
							category: departmentId
							categoryBreadcrumb
							categoryId
							categoryName
							countReview
							discountPercentage
							gaKey
							imageUrl
							labelGroups {
								position
								title
								type
								url
								__typename
							}
							originalPrice
							price
							priceRange
							rating
							ratingAverage
							shop {
								shopId: id
								name
								url
								city
								isOfficial
								isPowerBadge
								__typename
							}
							url
							wishlist
							sourceEngine: source_engine
							__typename
						}
						__typename
					}
					__typename
				}
			}
			"
				}
			])
			req_options = {
				use_ssl: uri.scheme == "https",
			}
			response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
				http.request(request)
			end

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
