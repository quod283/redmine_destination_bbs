class AddConditionToRedmineDestinationBbsModels < ActiveRecord::Migration[5.2]
    def up
        add_column :redmine_destination_bbs_models, :condition, :string
    end
  end