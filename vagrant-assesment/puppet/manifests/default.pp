
package{'git': ensure => installed }

package{'python3-pip': ensure => latest }


vcsrepo { '/opt/email-processor':
  ensure     => latest,
  provider   => git,
#  source     => 'https://github.com/InnovativeTravel/email-processor',
  source     => 'https://bitbucket.org/pmoranga/innovativetravel-email-processor.git',
  require    => Package['git'],
  submodules => true,
  revision => 'pedro',
#   identity => '/home/innovativetravel/github-deploy.pem,
}

exec{'emailprocessor-install':
	command      => '/usr/bin/pip3 install .',
	cwd          => '/opt/email-processor',
	refreshonly  => true,
	subscribe    => Vcsrepo['/opt/email-processor'],
	require      => Package['python3-pip'],
}



