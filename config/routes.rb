# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
    resources :redmine_destination_bbs do
        collection do
            get 'report'
        end
    end

    resources :attendance_location do
        collection do
        end
    end
end