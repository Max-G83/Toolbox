class AppsController < ApplicationController
  def locations
  end

  def restock_clear
  end

  def labels
  end

  def quote
  end

  def login
    @response = App.login(params[:username], params[:password])
    flash[:notice] = 'Login unsuccessful!' if @response.code != '200'
    render :locations
  end
end
