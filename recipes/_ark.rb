# Cookbook Name:: tomcat
# Recipe:: _ark
#

tomcat_service = "tomcat#{node[:tomcat][:version]}"

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
  home node[:tomcat][:home_dir]
  gid node[:tomcat][:group]
  system true
end

# Download and install
ark 'tomcat' do
  url node[:tomcat][:url]
  checksum node[:tomcat][:checksum]
  version node[:tomcat][:version]
  prefix_root node[:tomcat][:prefix_dir]
  home_dir node[:tomcat][:home_dir]
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
end

# Tomcat main configuration file
case node[:tomcat][:version]
when '5', '55'
  server_template = "server5.xml.erb"
else
  server_template = "server.xml.erb"
end

template "#{node[:tomcat][:conf_dir]}/server.xml" do
  source server_template
  mode 00664
  variables(
    :tomcat_version => node[:tomcat][:version].to_i,
    :tomcat_port => node[:tomcat][:port],
    :tomcat_ajp_port => node[:tomcat][:ajp_port],

  )
  notifies :restart, "service[#{tomcat_service}]"
end

# Create Tomcat PID directory
directory node[:tomcat][:pid_dir] do
  owner node[:tomcat][:user]
  group node[:tomcat][:group]
  mode 00775
end

# Tomcat init script
template tomcat_service do
  path "/etc/init.d/#{tomcat_service}"
  source 'tomcat-init.erb'
  mode 00774
  variables(
    :tomcat_service => tomcat_service,
    :tomcat_user => node[:tomcat][:user],
    :catalina_base => node[:tomcat][:base_dir],
    :catalina_home => node[:tomcat][:home_dir],
    :catalina_opts => node[:tomcat][:catalina_opts],
    :catalina_pid => node[:tomcat][:pid_dir] + '/' + tomcat_service,
    :catalina_tmp => node[:tomcat][:tmp_dir],
    :java_home => node[:java][:java_home],
    :java_opts => node[:tomcat][:java_opts],
    :tomcat_lock => node[:tomcat][:lock_dir] + '/' + tomcat_service
  )
end

# Tomcat service
service tomcat_service do
  supports :restart => true, :reload => true, :status => true
  action [:enable, :start]
  retries 2
  retry_delay 15
end