#
# Cookbook Name:: tomcat
# Recipe:: users
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2010-2012, Opscode, Inc.
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

template "#{node[:tomcat][:config_dir]}/tomcat-users.xml" do
  source 'tomcat-users.xml.erb'
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode '0644'
  variables(
    :users => TomcatCookbook.users,
    :roles => TomcatCookbook.roles,
  )
  notifies :restart, "service[#{node[:tomcat][:service]}]"
end
