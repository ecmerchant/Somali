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
      logger.debug("post")
      res = 'no data'
      body = params[:data]
      rnum = params[:rnum].to_i
      res = JSON.parse(body)
      logger.debug(res)
      ps = Product.where(user: current_user.email)
      res.each do |r|
        ps.find_or_create_by(asin: r)
      end

      user = current_user.email
      asin = res[rnum]
      logger.debug("==== Get Start ====")
      logger.debug(asin)
      logger.debug(rnum)
      logger.debug("==== ==== ====")
      
      temp = Product.new
      result = temp.collect(user, asin)

      render json: result
    else
      logger.debug("other")
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
     params.require(:account).permit(:user, :seller_id, :mws_auth_token)
  end

end
