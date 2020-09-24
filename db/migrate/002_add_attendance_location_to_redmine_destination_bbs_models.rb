class AddAttendanceLocationToRedmineDestinationBbsModels < ActiveRecord::Migration[5.2]
    def up
        add_column :redmine_destination_bbs_models, :attendance_location, :string
    end
  end