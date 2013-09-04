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
    response = App.login(params[:username], params[:password])
    if response.code != '200'
      flash[:notice] = 'Login unsuccessful!'
      redirect_to :back and return
    end
    session[:redirect_to] = request.referer
    redirect_to :customers
  end

  def customers
    # grab Apex data here so it's done less often
    session[:customers] = App.customers
    session[:machines] = App.machines
    redirect_to session[:redirect_to], :flash => { :customers => session[:customers] }
  end

  def machines
    machines = session[:machines].select { |k,v| session[:machines][k]['siteId'] == params[:customer_id]}
    redirect_to session[:redirect_to], :flash => { :customers => session[:customers], :machines => machines }
  end
end
