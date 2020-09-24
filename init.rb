Redmine::Plugin.register :redmine_destination_bbs do
  name 'Redmine Destination BBS plugin'
  author 'quod283'
  description 'This is a plugin for Redmine'
  version '0.4.0'
  url ''
  author_url ''
  menu :top_menu, :redmine_destination_bbs,
  {:controller => 'redmine_destination_bbs', :action => 'index'},
  :caption => :title_destination_bbs
  menu :admin_menu, 'icon icon-list enumerations',
  {:controller => 'attendance_location', :action => 'index'},
  :caption => :title_attendance_location_list
end
