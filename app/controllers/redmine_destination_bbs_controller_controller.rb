class RedmineDestinationBbsControllerController < ApplicationController
  unloadable
  def index

    @search_params = destination_bbs_search_params

    if (@search_params.blank?)
      @destination_bbs = RedmineDestinationBbsModel.where(registration_date: Date.today)
      @search_params_date = Date.today
    else
      @destination_bbs = RedmineDestinationBbsModel.search(@search_params)
      @search_params_date = @search_params[:registration_date]
    end
    @users = User.select('id', 'lastname', 'firstname')
    @user_id = User.current.attributes["id"]
    @destination_bbs_id = RedmineDestinationBbsModel.where(user_id: @user_id, registration_date: Date.today).select('id')
  end

  def create
    @destination_bbs = RedmineDestinationBbsModel.new(params[:destination_bbs])
    @destination_bbs.user_id = params[:user_id]
    @destination_bbs.destination = params[:destination]
    @destination_bbs.registration_date = Date.today
    @destination_bbs.start_time = params[:start_time]

    if @destination_bbs.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back(fallback_location: {:controller => 'redmine_destination_bbs_controller', :action => 'index'})
    end
  end

  def update
    @destination_bbs = RedmineDestinationBbsModel.where(user_id: params[:user_id], registration_date: Date.today)
    if @destination_bbs.update(destination: params[:destination], end_time: params[:end_time])
      flash[:notice] = l(:notice_successful_update)
      redirect_back(fallback_location: {:controller => 'redmine_destination_bbs_controller', :action => 'index'})
    end 
  end

  private

  def destination_bbs_search_params
    params.fetch(:search, {}).permit(:registration_date)
  end

end
