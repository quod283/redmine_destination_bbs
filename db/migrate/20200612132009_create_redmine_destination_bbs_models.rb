class CreateRedmineDestinationBbsModels < ActiveRecord::Migration[5.2]
  def change
    create_table :redmine_destination_bbs_models do |t|
      t.integer :user_id
      t.string :destination
      t.datetime :start_time
      t.datetime :end_time
      t.date :registration_date
      t.text :comment
    end
  end
end
