#
# Cookbook Name:: fluentd
#
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

default['fluentd']['gem_version'] = "0.12.26" # latest version compatible with ruby 1.9.x
default['fluentd']['user']  = "fluent"
default['fluentd']['group'] = "fluent"

default['fluentd']['plugins']       = []
default['fluentd']['configs']       = []
default['fluentd']['clear_configs'] = false
default['fluentd']['data_bag_name'] = "fluentd"

# Ruby. If the version is set to nil ruby will not be installed.
default['fluentd']['ruby']['version'] = "2.3"
default['fluentd']['ruby']['packages'] = [
  "ruby#{node['fluentd']['ruby']['version']}",
  "ruby#{node['fluentd']['ruby']['version']}-dev"
]
