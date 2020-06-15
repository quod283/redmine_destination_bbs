Redmine::Plugin.register :redmine_destination_bbs do
  name 'Redmine Destination Bbs plugin'
  author 'Trial Taro'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url ''
  author_url ''
  menu :top_menu, :redmine_destination_bbs, 
  {:controller => 'redmine_destination_bbs_controller', :action => 'index'},
  :caption => '行先掲示板'
end
