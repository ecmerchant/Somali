class ProductsController < ApplicationController

  require 'nokogiri'
  require 'uri'
  require 'csv'
  require 'peddler'
  require 'typhoeus'
  require 'date'
  require 'kconv'
  require 'activerecord-import'

  before_action :authenticate_user!, :except => [:regist]
  protect_from_forgery :except => [:regist]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def search
    @limit = ENV['MAX_ROWNUM']
    if @limit == nil then @limit = 1000 end
    logger.debug(@limit)
    @login_user = current_user
    @account = Account.find_or_create_by(user: current_user.email)
    @products = Product.where(user: current_user.email)
    if @products == nil then
      @products = Product.create(user: current_user.email)
    end
    @header = Product.column_names
    @header = [
      "asin",
      "new_sale1",
      "new_sale2",
      "new_sale3",
      "new_avg3",
      "used_sale1",
      "used_sale2",
      "used_sale3",
      "used_avg3",
      "check1",
      "cart_price",
      "cart_income",
      "used_price",
      "used_income",
      "check2",
      "title",
      "mpn",
      "item_image",
      "check3",
      "new_bid_price",
      "used_bid_price",
      "new_negotiate_price",
      "used_negotiate_price"
    ]

    if request.post? then
      logger.debug("post")
      res = 'no data'

      render json: ['no data']
    else
      logger.debug("other")
    end
  end


  def get
    if request.post? then
      body = params[:data]
      #rnum = params[:rnum].to_i
      res = JSON.parse(body)
      #logger.debug(res)
      user = current_user.email
      #data = res[rnum]
      data = res
      logger.debug("==== Get Start ====")
      logger.debug(data)
      #logger.debug(rnum)
      logger.debug("==== ==== ====")

      temp = Product.new
      result = temp.collect(user, data)

      render json: result
    else
      logger.debug("other")
    end
  end

  def record
    if request.post? then
      products = Product.where(user: current_user.email)
      body = params[:data]
      head =params[:header]
      body = JSON.parse(body)
      head = JSON.parse(head)
      logger.debug("====== BODY =======")
      logger.debug(body)
      logger.debug("====== HEAD =======")
      logger.debug(head)

      products.delete_all

      body.each do |row|
        if row[0] != "" then

          thash = Hash.new
          i = 0
          head.each_key do |key|
            if key != "item_image" then
              thash[key] = row[i]
            else
              thash[key] = /src="([\s\S]*?)"/.match(row[i])[1]
            end
            i += 1
          end
          logger.debug("====== HASH =======")
          logger.debug(thash)
          target = products.find_or_create_by(asin: row[0])
          if target != nil then
            target.update(thash)
          end
        end
      end

      render json: ["ok"]
    end
  end


  def setup
    @login_user = current_user
    @account = Account.find_or_create_by(user:current_user.email)
    if request.post? then
      @account.update(user_params)
    end
  end


  def delete
    @login_user = current_user
    temp = Product.where(user: current_user.email)
    if request.post? then
      temp.delete_all
    end
    render json: ["ok"]
  end

  def regist
    if request.post? then
      user = params[:user]
      password = params[:password]
      logger.debug("====== Regist from Form =======")
      logger.debug(user)
      logger.debug(password)
      tuser = User.find_or_initialize_by(email: user)
      if tuser.new_record? # 新規作成の場合は保存
        tuser = User.create(email: user, password: password)
      end
      Account.find_or_create_by(user: user)
      logger.debug("====== Regist from Form End =======")
    end
    redirect_to products_search_path
  end

  private
  def user_params
     params.require(:account).permit(:user, :seller_id, :mws_auth_token, :profit_rate, :shipping, :used_profit_rate)
  end

end
