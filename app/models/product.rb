class Product < ApplicationRecord

  require 'uri'
  require 'open-uri'
  require 'nokogiri'
  require 'date'

  def collect(user, data)
    logger.debug("====== Collect ========")
    asin = data[0]
    logger.debug(asin)
    check1 = data[9].to_s
    check2 = data[14].to_s
    check3 = data[18].to_s
    logger.debug(check1)
    logger.debug(check2)
    logger.debug(check3)

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

      hit = Product.where(user: user).find_or_create_by(asin: asin)

      result = {
        asin: asin,
        new_sale1: 0,
        new_sale2: 0,
        new_sale3: 0,
        used_sale1: 0,
        used_sale2: 0,
        used_sale3: 0,
        new_avg3: 0,
        used_avg3: 0,
        check1: check1,
        cart_price: 0,
        cart_income: 0,
        used_price: 0,
        used_income: 0,
        check2: check2,
        title: "※該当商品なし",
        mpn: "",
        item_image: "",
        check3: check3,
        new_bid_price: 0,
        used_bid_price: 0,
        new_negotiate_price: 0,
        used_negotiate_price: 0
      }
      hit.update(result)

      return result

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

    avg_new = (new_counter3) / 3
    if new_counter3 > 0 && avg_new == 0 then
      avg_new = 1
    end
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

    if avg_new == 0 && avg_used == 0 then
      puts '===== NO DATA ======'  
      hit = Product.where(user: user).find_or_create_by(asin: asin)

      result = {
        asin: asin,
        new_sale1: 0,
        new_sale2: 0,
        new_sale3: 0,
        used_sale1: 0,
        used_sale2: 0,
        used_sale3: 0,
        new_avg3: 0,
        used_avg3: 0,
        check1: check1,
        cart_price: 0,
        cart_income: 0,
        used_price: 0,
        used_income: 0,
        check2: check2,
        title: "※該当データなし",
        mpn: "",
        item_image: "",
        check3: check3,
        new_bid_price: 0,
        used_bid_price: 0,
        new_negotiate_price: 0,
        used_negotiate_price: 0
      }
      hit.update(result)

      return result
    end

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

    cart = html.match(/新品カート<\/strong>([\s\S]*?)<\/tr>/)
    if cart != nil then
      cart = cart[1]
      cart = cart.scan(/<strong>([\s\S]*?)<\/strong>/)
      if cart != nil then
        if cart[0] != nil then
          cart_price = cart[0][0].gsub(",","").to_i
          if cart[1] != nil then
            cart_profit = cart[1][0].gsub(",","").to_i
          else
            cart_profit = 0
          end
        else
          cart_price = 0
          cart_profit = 0
        end
      else
        cart_price = 0
        cart_profit = 0
      end
    else
      cart_price = 0
      cart_profit = 0
    end

    used = html.match(/中古<\/strong>([\s\S]*?)<\/tr>/)
    if used != nil then
      used = used[1]
      used = used.scan(/<strong>([\s\S]*?)<\/strong>/)
      if used != nil then
        if used[0] != nil then
          used_price = used[0][0].gsub(",","").to_i
          if used[1] != nil then
            used_profit = used[1][0].gsub(",","").to_i
          else
            used_profit = 0
          end
        else
          used_price = 0
          used_profit = 0
        end
      else
        used_price = 0
        used_profit = 0
      end
    else
      used_price = 0
      used_profit = 0
    end

    title = html.match(/<strong style="word-break:break-all;">([\s\S]*?)<\/strong>/)
    if title != nil then
      title = title[1]
      mpn = html.match(/<strong>規格番号：<\/strong><input class="selectable" value="([\s\S]*?)"/)[1]
      temp = html.match(/<table class="table-itemlist"([\s\S]*?)td>/)[1]
      image = temp.match(/src="([\s\S]*?)"/)[1]

      if check1 == "true" then
        cart_price = data[11].to_i
        cart_profit = data[12].to_i
        used_price = data[13].to_i
        used_profit = data[14].to_i
      end

      logger.debug(cart_price)
      logger.debug(cart_profit)
      logger.debug(used_price)
      logger.debug(used_profit)

      #計算
      tuser = Account.find_by(user: user)
      profit_rate = (tuser.profit_rate.to_f / 100.to_f).to_f
      used_profit_rate = (tuser.used_profit_rate.to_f / 100.to_f).to_f
      shipping = tuser.shipping

      puts profit_rate
      puts shipping

      if cart_price != 0 then
        new_bid_price = cart_profit.to_f - shipping.to_f - (cart_price.to_f * profit_rate).to_f
        new_bid_price = new_bid_price.round(-2)

        if cart_profit * (1.to_f - profit_rate).to_f < 10000 then
          temp = cart_profit.to_f * (1.to_f - profit_rate).to_f
          new_negotiate_price = (temp.to_i / 500.to_i) * 500
        else
          temp = cart_profit.to_f * (1.to_f - profit_rate).to_f
          new_negotiate_price = (temp.to_i / 1000.to_i) * 1000
        end
      else
        new_bid_price = 0
        new_negotiate_price = 0
      end

      if used_price != 0 then
        used_bid_price = used_profit.to_f - shipping.to_f - (used_price.to_f * used_profit_rate).to_f
        used_bid_price = used_bid_price.round(-2)

        if used_profit * (1.to_f - used_profit_rate).to_f < 10000 then
          temp = used_profit.to_f * (1.to_f - used_profit_rate).to_f
          used_negotiate_price = (temp.to_i / 500.to_i) * 500
        else
          temp = used_profit.to_f * (1.to_f - used_profit_rate).to_f
          used_negotiate_price = (temp.to_i / 1000.to_i) * 1000
        end

      else
        used_bid_price = 0
        used_negotiate_price = 0
      end
    else
      title = ""
      mpn = ""
      image = ""
    end

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

    if check1 == "true" then
      logger.debug("check1")
      cart_price = data[10].to_i
      cart_income = data[11].to_i
      used_price = data[12].to_i
      used_income = data[13].to_i
    end

    if check2 == "true" then
      logger.debug("check2")
      title = data[15].to_s
      mpn = data[16].to_s
      image = /src="([\s\S]*?)"/.match(data[17])[1]
    end

    if check3 == "true" then
      logger.debug("check3")
      new_bid_price = data[19].to_i
      used_bid_price = data[20].to_i
      new_negotiate_price = data[21].to_i
      used_negotiate_price = data[22].to_i
    end

    used_counter3 = used_counter3 - used_counter2
    used_counter2 = used_counter2 - used_counter1
    new_counter3 = counter3 - counter2 - used_counter3
    new_counter2 = counter2 - counter1 - used_counter2
    new_counter1 = counter1 - used_counter1

    avg_new = (new_counter3 + new_counter2 + new_counter1) / 3

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
      check1: check1,
      cart_price: cart_price,
      cart_income: cart_profit,
      used_price: used_price,
      used_income: used_profit,
      check2: check2,
      title: title,
      mpn: mpn,
      item_image: image,
      check3: check3,
      new_bid_price: new_bid_price,
      used_bid_price: used_bid_price,
      new_negotiate_price: new_negotiate_price,
      used_negotiate_price: used_negotiate_price
    }
    hit.update(result)

    return result

  end

end
