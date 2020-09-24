class AttendanceLocationController < ApplicationController
    unloadable

    def index
        @attendance_location_list = AttendanceLocation.all.first
        if @attendance_location_list.blank?
        else
            @attendance_location_list_id = @attendance_location_list.id
        end
    end

    def create
        @attendance_location_list = AttendanceLocation.new
        @attendance_location_list.location_list = params[:location_list]
        if @attendance_location_list.save
            flash[:notice] = l(:notice_successful_create)
            move_to_index
        end
    end

    def update
        @attendance_location_list = AttendanceLocation.first
        if @attendance_location_list.update(location_list: params[:location_list])
            flash[:notice] = l(:notice_successful_update)
            move_to_index
        end
    end

    private

    # indexリダイレクト用
    def move_to_index
        redirect_back(fallback_location: {:controller => 'attendance_location', :action => 'index'})
    end

end