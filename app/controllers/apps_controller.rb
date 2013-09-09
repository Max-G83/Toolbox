class AppsController < ApplicationController
  layout 'apps'

  def locations
    if session[:logged_in].present?
      session[:customers] = App.customers
      session[:machines] = App.machines
    end
    # so naive ...
    if params[:customer_id].present? and !params[:machine_id].present? and !params[:begin_date].present? and !params[:begin_time].present?
      flash[:machines] = session[:machines].select { |k,v| session[:machines][k]['siteId'] == params[:customer_id]}
      flash[:selected] = params[:customer_id]
      render 'locations'
    end
    if params[:machine_id].present? and params[:begin_date].present? and params[:begin_time].present?
      @report = Location.calculate(params[:customer_id], params[:machine_id], params[:begin_date], params[:begin_time])
      render 'locations'
    end
  end

  def restock_clear
  end

  def labels
  end

  def quote
  end

  def login
    name = App.login(params[:username], params[:password])
    if name.present?
      session[:logged_in] = name['name']
    else
      flash[:notice] = 'Login unsuccessful!'
    end
    redirect_to :back
  end

  def logout
    session.destroy
    #App.username, App.password = nil, nil
    redirect_to :back
  end
end
