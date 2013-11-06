class zulip::local_server {
  include zulip::base
  include zulip::app_frontend
  include zulip::postgres_appdb
  include zulip::camo

  apt::key {"A529EF65":
    source  =>  "http://apt.zulip.com/enterprise.asc",
  }

  file { "/etc/nginx/sites-available/zulip-local":
    require => Package[nginx],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/sites-available/zulip-local",
  }
  file { '/etc/nginx/sites-enabled/zulip-local':
    ensure => 'link',
    target => '/etc/nginx/sites-available/zulip-local',
  }
  file { '/home/zulip/deployments/current':
    ensure => 'link',
    target => '/home/zulip/zulip',
  }
  file { '/home/zulip/prod-static':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }

  file { '/etc/postgresql/9.1/main/postgresql.conf.template':
    ensure => file,
    owner  => "postgres",
    group  => "postgres",
    mode   => 644,
    source => "puppet:///modules/zulip/postgresql/postgresql.conf.template"
  }

  exec { 'pgtune':
    require => Package[pgtune],
    command => 'pgtune -T Web -i /etc/postgresql/9.1/main/postgresql.conf.template -o /etc/postgresql/9.1/main/postgresql.conf',
    refreshonly => true,
    subscribe => File['/etc/postgresql/9.1/main/postgresql.conf.template']
  }

  exec { 'pg_ctlcluster 9.1 main restart':
    refreshonly => true,
    subscribe => Exec['pgtune']
  }
}
