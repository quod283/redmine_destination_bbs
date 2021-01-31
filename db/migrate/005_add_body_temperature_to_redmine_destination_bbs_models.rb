class AddBodyTemperatureToRedmineDestinationBbsModels < ActiveRecord::Migration[5.2]
    def up
        add_column :redmine_destination_bbs_models, :body_temperature,  :string
    end
  end