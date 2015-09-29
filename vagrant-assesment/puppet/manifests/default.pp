
package{'git': ensure => installed }
package{'python3-pip': ensure => latest }

$app_directory = '/var/email-processor'
$app_runas     = 'it_ep'
$app_env_file  = '/etc/app-env.sh'

user { $app_runas :
  ensure     => present,
  managehome => false,
  system     => true,
}

file {$app_directory:
  ensure  => directory,
  owner   => $app_runas,
  require => User[$app_runas],
}

vcsrepo { '/opt/email-processor':
  ensure     => latest,
  provider   => git,
#  source     => 'https://github.com/InnovativeTravel/email-processor',
  source     => 'https://bitbucket.org/pmoranga/innovativetravel-email-processor.git',
  require    => Package['git'],
  submodules => true,
  revision   => 'pedro',
#   identity => '/etc/app-deploy.pem,
}

exec{'emailprocessor-install':
  command     => '/usr/bin/pip3 install --upgrade .',
  cwd         => '/opt/email-processor',
  refreshonly => true,
  subscribe   => Vcsrepo['/opt/email-processor'],
  require     => Package['python3-pip'],
}

class { 'supervisord':
  install_pip   => true,
  init_template => 'it_emailprocessor/Debian-defaults.erb',
  unix_socket_mode  => '0770',
}

supervisord::program { 'emailprocessor':
  command                 => '/usr/local/bin/emailprocessor bing_to_s3',
  priority                => '100',
  redirect_stderr         => true,
  stopsignal              => 'INT',
  directory               => $app_directory,
  require                 => Exec['emailprocessor-install'],
  user                    => $app_runas,
  stdout_logfile_maxbytes => '20MB',
}

supervisord::supervisorctl { 'restart_emailprocessor':
  command     => 'restart',
  process     => 'emailprocessor',
  refreshonly => true,
  subscribe   => Exec['emailprocessor-install'],
}


# Auxiliary programs, should be in state stopped.
supervisord::program { 'emailprocessor-save_attachments':
  command         => '/usr/local/bin/emailprocessor save_attachments',
  autostart       => false,
  ensure_process  => 'stopped',
  priority        => '999',
  redirect_stderr => true,
  stopsignal      => 'INT',
  directory       => $app_directory,
  autorestart     => false,
  require         => Exec['emailprocessor-install'],
  user            => $app_runas,
}

supervisord::program { 'emailprocessor-email_summary':
  command         => '/usr/local/bin/emailprocessor email_summary',
  autostart       => false,
  ensure_process  => 'stopped',
  priority        => '998',
  redirect_stderr => true,
  stopsignal      => 'INT',
  directory       => $app_directory,
  autorestart     => false,
  require         => Exec['emailprocessor-install'],
  user            => $app_runas,
}

# SNS related items
exec{'install_awscli':
  command => '/usr/bin/pip3 install awscli',
  require => Package['python3-pip'],
  creates => '/usr/local/bin/aws',
}

file { '/usr/local/bin/alert_sns.sh':
  content => template('it_emailprocessor/alert_sns.sh.erb'),
  mode    => '0755',
}

exec {'first_run_alert_sns':
  command   => '/usr/local/bin/alert_sns.sh',
  creates   => '/etc/app-sns',
  logoutput => true,
  require   =>  [ File['/usr/local/bin/alert_sns.sh'], Exec['install_awscli']]
}

# Monitoring
class { "datadog_agent":
  api_key => "bcbb46c5cd3068f5bc62aab08687170f"
}

file { 
  '/etc/dd-agent/conf.d/supervisord.yaml':
    content => template('it_emailprocessor/dd_supervisor.yaml.erb'),
    notify  => Service[$::datadog_agent::params::service_name];
  '/etc/dd-agent/conf.d/process.yaml':
    content => template('it_emailprocessor/dd_processes.yaml.erb'),
    notify  => Service[$::datadog_agent::params::service_name];
}
