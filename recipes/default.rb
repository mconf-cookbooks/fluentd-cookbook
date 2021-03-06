#
# Cookbook Name:: fluentd
# Recipe:: default
#
# Copyright 2013, Dmytro Kovalov
# Copyright 2015, Felipe Cecagno
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
group node['fluentd']['group'] do
  group_name node['fluentd']['group']
  action     [:create]
end

user node['fluentd']['user'] do
  comment  'fluent'
  group    node['fluentd']['group']
  home     "/var/run/#{node['fluentd']['user']}"
  shell    '/bin/false'
  password nil
  supports :manage_home => true
  action   [:create, :manage]
end

directory "/etc/fluent/config.d" do
  recursive true
  action :delete
  only_if { node['fluentd']['clear_configs'] }
end

%w{ /etc/fluent/ /etc/fluent/config.d/ /var/log/fluent/ /usr/local/fluent/ }.each do |dir|
  directory dir do
    owner  node['fluentd']['user']
    group  node['fluentd']['group']
    mode   '0755'
    action :create
  end
end

template "/etc/fluent/fluent.conf" do
  mode "0644"
  source "fluent.conf.erb"
end

template "/etc/init.d/fluent" do
  mode "0755"
  source "fluent.init_d.erb"
end

template "/usr/local/fluent/Gemfile" do
  source "Gemfile.erb"
  variables ({
    :fluentd_version => node['fluentd']['gem_version'],
    :plugins => node['fluentd']['plugins']
  })
end
file "/usr/local/fluent/Gemfile.lock" do
  action :delete
end

if node['fluentd']['ruby']['packages']
  apt_repository 'ruby-ng' do
    uri 'ppa:brightbox/ruby-ng'
    components ['main']
  end
  node['fluentd']['ruby']['packages'].each do |name|
    package name
  end
end

gem_package "bundler"

execute "install fluent" do
  cwd "/usr/local/fluent/"
  command "bundle install"
  action :run
end

service "fluent" do
  action :nothing
  supports [ :enable, :start, :restart ]
end

#
# Handle sources and matches configuration
#
node['fluentd']['configs'].each do |data_bag_id|
  data_bag = Chef::DataBagItem.load(node['fluentd']['data_bag_name'], data_bag_id).raw_data

  data_bag['source'].each do |config|
    cfg = config.dup
    template "#{config['tag']}" do
      path      "/etc/fluent/config.d/source_#{config['tag']}.conf"
      helpers(Fluentd::Helpers)
      source    "plugin_source.conf.erb"
      variables({ :attributes => cfg })
      notifies :restart, "service[fluent]", :delayed
    end
  end unless data_bag['source'].nil?

  data_bag['match'].each do |config|
    cfg = config.dup
    template "#{cfg['match']}" do
      path      "/etc/fluent/config.d/match_#{cfg['match']}.conf"
      helpers(Fluentd::Helpers)
      source    "plugin_match.conf.erb"
      variables({ :match => cfg.delete('match'), :attributes => cfg })
      notifies :restart, "service[fluent]", :delayed
    end
  end unless data_bag['match'].nil?

  data_bag['filter'].each do |config|
    cfg = config.dup
    template "#{cfg['filter']}" do
      path      "/etc/fluent/config.d/filter_#{cfg['match']}.conf"
      helpers(Fluentd::Helpers)
      source    "plugin_filter.conf.erb"
      variables({ :match => cfg.delete('match'), :attributes => cfg })
      notifies :restart, "service[fluent]", :delayed
    end
  end unless data_bag['filter'].nil?
end
