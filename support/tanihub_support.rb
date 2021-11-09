class TanihubSupport
	def self.curl_command(product_keyword)
		uri = URI.parse("https://tanihub.com/call")
		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/json"
		request["Cache-Control"] = "no-cache"
		request["Postman-Token"] = "50dc4204-8aa0-a5d3-4407-1d3f0e18e351"
		request.body = JSON.dump({
			"url" => "v2/product-search",
			"method" => "post",
			"body" => {
				"query" => "
		query sellings(
			$from: Int,
			$size: Int,
			$regionId: Int,
			$regionSlug: String,
			$groupId: Int,
			$nowDate: String,
			$sortField: String,
			$sortOrder: String,
			$searchKey: String,
			$randomizerSeed: Float,
			$relatedName: String,
			$relatedId: Int,
			$isPromoted: Boolean,
			$isFlashsale: Boolean,
		) {
			sellings(
				from: $from,
				size: $size,
				regionId: $regionId,
				regionSlug: $regionSlug,
				groupId: $groupId,
				nowDate: $nowDate,
				sortField: $sortField,
				sortOrder: $sortOrder,
				searchKey: $searchKey,
				randomizerSeed: $randomizerSeed,
				relatedName: $relatedName,
				relatedId: $relatedId,
				isPromoted: $isPromoted,
				isFlashsale: $isFlashsale,
			) {
				count
				totalPages
				currentPage
				params {
					from
					size
					sortField
					sortOrder
					regionId
					searchKey
				}
				items {
					id
					product {
						id
						name
						slug
						commercialSkuContent
						brand {
							name
						}
						productImages {
							isDefault
							imageURL
						}
						unit {
							description
						}
						productPackaging {
							id
							name
							multiplier
						}
						groups {
							id
							name
							imageUrl
						}
						grade {
							id
						}
					}
					productPrices {
						id
						discount
						discountType
						minQty
						maxQty
						price
					}
					discount
					discountInRupiah
					discountType
					minOrder
					maxOrder
					isActive
					showedPrice
					showedPriceAfterDiscount
					stockLowerLimit
					stockQty
					isFlashsale
				}
			}
		}
		",
				"variables" => {
					"from" => 0,
					"regionId" => 1,
					"searchKey" => "#{product_keyword}",
					"size" => 24,
					"sortField" => "_score",
					"sortOrder" => "desc"
				}
			},
			"headers" => {}
		})
		
		req_options = {
			use_ssl: uri.scheme == "https",
		}
		
		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
			http.request(request)
		end
	end
end