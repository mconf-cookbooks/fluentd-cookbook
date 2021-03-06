name             'fluentd'
maintainer       'Dmytro Kovalov'
maintainer_email 'dmytro.kovalov@gmail.com'
license          'MIT'
description      'Installs/Configures fluentd'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.7'

%w{redhat centos debian ubuntu}.each do |os|
  supports os
end

depends 'apt', '>= 2.9'

attribute "fluentd/plugins",
  :display_name => "List of plugins",
  :description => "List of plugins to install together with fluentd",
  :default => ''

attribute "fluentd/configs/source",
  :display_name => "Sources configuration",
  :description => "List of sources for generating config file(s)",
  :default => ''

attribute "fluentd/configs/match",
  :display_name => "Matches configuration",
  :description => "List of matches for generating config file(s)",
  :default => ''

attribute "fluentd/configs/filter",
  :display_name => "Filters configuration",
  :description => "List of filters for generating config file(s)",
  :default => ''
