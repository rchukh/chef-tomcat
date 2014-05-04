#
# Cookbook Name:: tomcat
# Recipe:: default
#

unless platform_family?('rhel')
  Chef::Application.fatal!("Cookbook incompatible with #{platform_family?}")
end

# Install Java using Opscode Java cookbook
include_recipe 'java'
include_recipe 'tomcat::base'
