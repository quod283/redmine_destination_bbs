class RedmineDestinationBbsModel < ActiveRecord::Base
    unloadable

    scope :search, -> (search_params) do
        return if search_params.blank?

        registration_date_is(search_params[:registration_date])
    end
    scope :registration_date_is, -> (registration_date) { where(registration_date: registration_date) if registration_date.present?}
end
