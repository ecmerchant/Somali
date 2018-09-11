class Product < ApplicationRecord

  require 'uri'
  require 'open-uri'
  require 'nokogiri'
  require 'date'

  def collect(user, asin)
    puts asin
    url = 'https://delta-tracer.com/item/chart_html/jp/' + asin
    charset = nil
    begin
      html = open(url) do |f|
        charset = f.charset
        f.read # htmlを読み込んで変数htmlに渡す
      end
    rescue OpenURI::HTTPError => error
      logger.debug("===== ERROR =====")
      logger.debug(error)
    end

    json = html.match(/JSON.parse\('([\s\S]*?)'/)[1]
    rawdata = JSON.parse(json)

    timestamp = rawdata['timestamp']
    new_count = rawdata['data']['new_count']
    used_count = rawdata['data']['used_count']
    sales_rank = rawdata['data']['sales_rank']

    new_counter1 = 0
    new_counter2 = 0
    new_counter3 = 0

    used_counter1 = 0
    used_counter2 = 0
    used_counter3 = 0

    counter1 = 0
    counter2 = 0
    counter3 = 0

    d1 = 1.months.ago.to_i * 1000
    d2 = 2.months.ago.to_i * 1000
    d3 = 3.months.ago.to_i * 1000

    timestamp.each.with_index(1)  do |tt, j|

      diff = sales_rank[j].to_i - sales_rank[j-1].to_i
      new_diff = new_count[j].to_i - new_count[j-1].to_i
      used_diff = used_count[j].to_i - used_count[j-1].to_i

      if diff < (sales_rank[j-1].to_i*0.05*(-1)) then
        if tt > d3 then
          if new_diff < 0 then
            new_counter3 += 1
          end
          if used_diff < 0 then
            used_counter3 += 1
          end
          counter3 += 1

          if tt > d2 then
            if new_diff < 0 then
              new_counter2 += 1
            end
            if used_diff < 0 then
              used_counter2 += 1
            end
            counter2 += 1

            if tt > d1 then
              if new_diff < 0 then
                new_counter1 += 1
              end
              if used_diff < 0 then
                used_counter1 += 1
              end
              counter1 += 1
            end
          end
        end
      end
    end

    avg_new = (counter3 - (used_counter3)) / 3
    avg_used = (used_counter3) / 3

    puts '===== VALUES ======'
    puts "avg_new=" + avg_new.to_s
    puts "avg_used=" + avg_used.to_s
    puts "new_counter1=" + new_counter1.to_s
    puts "new_counter2=" + new_counter2.to_s
    puts "new_counter3=" + new_counter3.to_s
    puts "used_counter1=" + used_counter1.to_s
    puts "used_counter2=" + used_counter2.to_s
    puts "used_counter3=" + used_counter3.to_s
    puts '===== END ======'

    url = "https://delta-tracer.com/item/detail/jp/" + asin
    charset = nil
    html = nil
    begin
      html = open(url) do |f|
        charset = f.charset
        f.read # htmlを読み込んで変数htmlに渡す
      end
    rescue OpenURI::HTTPError => error
      logger.debug("===== ERROR =====")
      logger.debug(error)
    end

    cart = html.match(/新品カート<\/strong>([\s\S]*?)<\/tr>/)[1]
    cart = cart.scan(/<strong>([\s\S]*?)<\/strong>/)
    if cart != nil then
      if cart[0] != nil then
        cart_price = cart[0][0].gsub(",","")
        cart_profit = cart[1][0].gsub(",","")
      else
        cart_price = 0
        cart_profit = 0
      end
    else
      cart_price = 0
      cart_profit = 0
    end

    used = html.match(/中古<\/strong>([\s\S]*?)<\/tr>/)[1]
    used = used.scan(/<strong>([\s\S]*?)<\/strong>/)
    if used != nil then
      if used[0] != nil then
        used_price = used[0][0].gsub(",","")
        used_profit = used[1][0].gsub(",","")
      else
        used_price = 0
        used_profit = 0
      end
    else
      used_price = 0
      used_profit = 0
    end
    title = html.match(/<strong style="word-break:break-all;">([\s\S]*?)<\/strong>/)[1]
    mpn = html.match(/<strong>規格番号：<\/strong><input class="selectable" value="([\s\S]*?)"/)[1]
    temp = html.match(/<table class="table-itemlist"([\s\S]*?)td>/)[1]
    image = temp.match(/src="([\s\S]*?)"/)[1]

    puts '===== VALUES ======'
    puts "title=" + title.to_s
    puts "mpn=" + mpn.to_s
    puts "image=" + image.to_s
    puts "cart_price=" + cart_price.to_s
    puts "cart_profit=" + cart_profit.to_s
    puts "used_price=" + used_price.to_s
    puts "used_profit=" + used_profit.to_s
    puts '===== END ======'

    hit = Product.where(user: user).find_or_create_by(asin: asin)
    hit.update(
      new_sale1: new_counter1,
      new_sale2: new_counter2,
      new_sale3: new_counter3,
      used_sale1: used_counter1,
      used_sale2: used_counter2,
      used_sale3: used_counter3,
      new_avg3: avg_new,
      used_avg3: avg_used,
      cart_price: cart_price,
      cart_income: cart_profit,
      used_price: used_price,
      used_income: used_profit,
      title: title,
      mpn: mpn,
      item_image: image
    )

    result = {
      asin: asin,
      new_sale1: new_counter1,
      new_sale2: new_counter2,
      new_sale3: new_counter3,
      used_sale1: used_counter1,
      used_sale2: used_counter2,
      used_sale3: used_counter3,
      new_avg3: avg_new,
      used_avg3: avg_used,
      cart_price: cart_price,
      cart_income: cart_profit,
      used_price: used_price,
      used_income: used_profit,
      title: title,
      mpn: mpn,
      item_image: image
    }

    return result

  end

end
