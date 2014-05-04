# Cookbook Name:: tomcat
# Recipe:: _ark
#
include_recipe 'ark'

# Create Tomcat group
group node[:tomcat][:group] do
  action :create
  system true
end

# Create Tomcat user
user node[:tomcat][:user] do
  action :create
  comment "Tomcat application server"
  home node[:tomcat][:home]
  gid node[:tomcat][:group]
  system true
end

# Download and install
ark 'tomcat' do
  url node[:tomcat][:url]
  checksum node[:tomcat][:checksum]
  version node[:tomcat][:base_version]
  prefix_root node[:tomcat][:prefix_dir]
  home_dir node[:tomcat][:home]
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
end

# Tomcat main configuration file
case node[:tomcat][:base_version]
when '5', '55'
  server_template = "server5.xml.erb"
else
  server_template = "server.xml.erb"
end

template "#{node[:tomcat][:config_dir]}/server.xml" do
  source server_template
  mode 00664
  notifies :restart, "service[#{node[:tomcat][:service]}]"
end

# Create Tomcat PID directory
directory node[:tomcat][:pid_dir] do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode 00775
end

# Tomcat init script
template node[:tomcat][:service] do
  path "/etc/init.d/#{node[:tomcat][:service]}"
  source 'tomcat-init.erb'
  mode 00774
  variables(
    :tomcat_service => node[:tomcat][:service],
    :tomcat_user => node[:tomcat][:user],
    :catalina_base => node[:tomcat][:base],
    :catalina_home => node[:tomcat][:home],
    :catalina_opts => node[:tomcat][:catalina_options],
    :catalina_pid => node[:tomcat][:pid_dir] + '/' + node[:tomcat][:service],
    :catalina_tmp => node[:tomcat][:tmp_dir],
    :java_home => node[:java][:java_home],
    :java_opts => node[:tomcat][:java_options],
    :tomcat_lock => node[:tomcat][:lock_dir] + '/' + node[:tomcat][:service]
  )
end

# Tomcat service
service node[:tomcat][:service] do
  supports :restart => true, :reload => true, :status => true
  action [:enable, :start]
  retries 2
  retry_delay 15
end
