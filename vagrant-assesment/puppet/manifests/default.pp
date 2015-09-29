
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
#   identity => '/home/innovativetravel/github-deploy.pem,
}

exec{'emailprocessor-install':
  command     => '/usr/bin/pip3 install .',
  cwd         => '/opt/email-processor',
  refreshonly => true,
  subscribe   => Vcsrepo['/opt/email-processor'],
  require     => Package['python3-pip'],
}

class { 'supervisord':
  install_pip   => true,
  init_template => 'it_emailprocessor/Debian-defaults.erb',
}

supervisord::program { 'emailprocessor':
  command         => '/usr/local/bin/emailprocessor bing_to_s3',
  priority        => '100',
  redirect_stderr => true,
  stopsignal      => 'INT',
  directory       => $app_directory,
  require         => Exec['emailprocessor-install'],
  user            => $app_runas,
}

# supervisord::supervisorctl { 'restart_myapp':
#  command     => 'restart',
#  process     => 'emailprocessor'
#  refreshonly => true,
#  subscribe   => Exec['emailprocessor-install'],
#}


supervisord::program { 'emailprocessor-save_attachments':
  command         => '/usr/local/bin/emailprocessor save_attachments',
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
  ensure_process  => 'stopped',
  priority        => '998',
  redirect_stderr => true,
  stopsignal      => 'INT',
  directory       => $app_directory,
  autorestart     => false,
  require         => Exec['emailprocessor-install'],
  user            => $app_runas,
}
