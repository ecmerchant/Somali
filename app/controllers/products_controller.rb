class ProductsController < ApplicationController

  require 'nokogiri'
  require 'uri'
  require 'csv'
  require 'peddler'
  require 'typhoeus'
  require 'date'
  require 'kconv'
  require 'activerecord-import'

  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def search
    @login_user = current_user
    @account = Account.find_or_create_by(user: current_user.email)
    @products = Product.where(user: current_user.email)
    if @products == nil then
      @products = Product.create(user: current_user.email)
    end
    @header = Product.column_names

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
      rnum = params[:rnum].to_i
      res = JSON.parse(body)
      logger.debug(res)
      user = current_user.email
      data = res[rnum]
      logger.debug("==== Get Start ====")
      logger.debug(data)
      logger.debug(rnum)
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
          target = products.find_by(asin: row[0])
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

  private
  def user_params
     params.require(:account).permit(:user, :seller_id, :mws_auth_token, :profit_rate, :shipping, :used_profit_rate)
  end

end
