# == Class: supervisor
#
# Puppet supervisor module.
#
class supervisor (
  $ensure                       = 'present',
  $manage_package               = true,
  $supervisor_bin_path          = '/usr/local/bin',
  # Defaults for [unix_http_server] section.
  $unix_http_server             = true,
  $unix_http_server_file        = '/var/run/supervisor.sock',
  $unix_http_server_chmod       = '0700',
  $unix_http_server_chown       = undef,
  $unix_http_server_username    = undef,
  $unix_http_server_password    = undef,
  # Defaults for [inet_http_server] section.
  $inet_http_server             = false,
  $inet_http_server_port        = undef,
  $inet_http_server_username    = undef,
  $inet_http_server_password    = undef,
  # Defaults for[supervisord] section.
  $supervisord                  = true,
  $supervisord_logfile          = '/var/log/supervisor/supervisord.log',
  $supervisord_logfile_maxbytes = undef,
  $supervisord_logfile_backups  = undef,
  $supervisord_loglevel         = undef,
  $supervisord_pidfile          = '/var/run/supervisord.pid',
  $supervisord_umask            = '022',
  $supervisord_nodaemon         = false,
  $supervisord_minfds           = undef,
  $supervisord_minprocs         = undef,
  $supervisord_nocleanup        = undef,
  $supervisord_childlogdir      = '/var/log/supervisor',
  $supervisord_user             = undef,
  $supervisord_directory        = undef,
  $supervisord_strip_ansi       = undef,
  $supervisord_environment      = undef,
  $supervisord_identifier       = 'supervisor',
  # Defaults for [supervisorctl] section.
  $supervisorctl                = true,
  $supervisorctl_serverurl      = 'unix:///var/run/supervisor.sock',
  $supervisorctl_username       = undef,
  $supervisorctl_password       = undef,
  $supervisorctl_promt          = undef,
  $supervisorctl_history_file   = undef,
  # Daemon options.
  $supervisor_sysconfog_options = undef) inherits supervisor::params {

  $supervisor_package_name = $supervisor::params::supervisor_package_name
  $supervisor_service_name = $supervisor::params::supervisor_service_name
  $supervisor_conf_dir     = $supervisor::params::supervisor_conf_dir
  $supervisor_etc_dir      = $supervisor::params::supervisor_etc_dir
  $supervisor_sysconfig    = $supervisor::params::supervisor_sysconfig
  $supervisor_log_dir      = $supervisor::params::supervisor_log_dir

  if $supervisor_sysconfig_options == undef {
    $supervisor_sysconfig_options = 
    $supervisor::params::supervisor_sysconfig_options
  }

  file { $supervisor_etc_dir:
    ensure  => directory,
    mode    => '0755'
  }

  file { $supervisor_sysconfig:
    ensure  => present,
    path    => $supervisor_sysconfig,
    mode    => '0644',
    content => template('supervisor/supervisord.conf.erb'),
    require => File[$supervisor_etc_dir]
  }

  file { $supervisor_conf_dir:
    ensure  => directory,
    mode    => '0755',
    require => File[$supervisor_etc_dir]
  }

  file { $supervisor_log_dir:
    ensure  => directory,
    mode    => '0755',
  }

  file { "/lib/systemd/system/${supervisor_service_name}":
    ensure => $ensure,
    mode => '0770',
    content => template("supervisor/service.erb")
  } ~>
  exec { "${supervisor_service_name}-systemd-reload":
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }

  if ($manage_package)
  {
    package { $supervisor_package_name:
      ensure => $ensure,
      provider => "pip",
      require => [Package["python-pip"], File[$supervisor_conf_dir], File[$supervisor_sysconfig]]
    } -> File["/lib/systemd/system/${supervisor_service_name}"]
  }

  service { $supervisor_service_name:
    ensure => $ensure ? {
      'present' => running,
      'absent' => stopped
    },
    provider => systemd,
    enable => true,
    require => File["/lib/systemd/system/${supervisor_service_name}"]
  }

  # 01-unix_http_server.conf
  if ($unix_http_server) {
    file { "${supervisor_conf_dir}/01-unix_http_server.conf":
      ensure  => present,
      backup  => true,
      path    => "${supervisor_conf_dir}/01-unix_http_server.conf",
      mode    => '0644',
      content => template('supervisor/unix_http_server.conf.erb'),
      require => File[$supervisor_conf_dir],
      notify  => Service[$supervisor_service_name],
    }

    if ($manage_package)
    {
      Package[$supervisor_package_name] -> File["${supervisor_conf_dir}/02-inet_http_server.conf"]
    }
  }

  # 02-inet_http_server.conf
  if ($inet_http_server) {
    file { "${supervisor_conf_dir}/02-inet_http_server.conf":
      ensure  => present,
      backup  => true,
      path    => "${supervisor_conf_dir}/02-inet_http_server.conf",
      mode    => '0644',
      content => template('supervisor/inet_http_server.conf.erb'),
      require => File[$supervisor_conf_dir],
      notify  => Service[$supervisor_service_name],
    }

    if ($manage_package)
    {
      Package[$supervisor_package_name] -> File["${supervisor_conf_dir}/02-inet_http_server.conf"]
    }
  }

}
# EOF
