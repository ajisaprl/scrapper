class TokopediaSupport
	def self.curl_command(product_keyword)
		uri = URI.parse("https://gql.tokopedia.com/")
		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/json"
		request["Accept"] = "*/*"
		request["Accept-Language"] = "en-US,en;q=0.9"
		request["Authority"] = "gql.tokopedia.com"
		request["Cache-Control"] = "no-cache"
		request["Cookie"] = HTTParty.get("https://www.tokopedia.com/").headers["set-cookie"]
		request["Origin"] = "https://www.tokopedia.com"
		request["Postman-Token"] = "7ba5fe85-ac1a-905e-1b92-5e1d49356793"
		request["Referer"] = "https://www.tokopedia.com/search?st=product&q=#{product_keyword}&navsource=home"
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
								"params" => "navsource=home&q=#{product_keyword}&source=search_product&st=product"
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
								"params" => "device=desktop&navsource=home&ob=23&page=1&q=#{product_keyword}&related=true&rows=60&safe_search=false&scheme=https&shipping=&source=search&st=product&start=0&topads_bucket=true&unique_id=4576dae78a5cd70a7e501640d4a7bfb2&user_addressId=&user_cityId=176&user_districtId=2274&user_id=&user_lat=&user_long=&user_postCode=&variants="
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
	end
end