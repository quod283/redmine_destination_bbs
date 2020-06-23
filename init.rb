Redmine::Plugin.register :redmine_destination_bbs do
  name 'Redmine Destination BBS plugin'
  author 'quod283'
  description 'This is a plugin for Redmine'
  version '0.0.11'
  url ''
  author_url ''
  menu :top_menu, :redmine_destination_bbs, 
  {:controller => 'redmine_destination_bbs', :action => 'index'},
  :caption => :title_destination_bbs
end
