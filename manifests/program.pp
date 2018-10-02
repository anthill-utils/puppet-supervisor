# == Class: supervisor::program
#
define supervisor::program (
  $program_command,
  $ensure                          = present,
  $program_process_name            = undef,
  $program_numprocs                = undef,
  $program_numprocs_start          = undef,
  $program_priority                = undef,
  $program_autostart               = true,
  $program_autorestart             = true,
  $program_startsecs               = 5,
  $program_startretries            = undef,
  $program_exitcodes               = undef,
  $program_stopsignal              = undef,
  $program_stopwaitsecs            = 10,
  $program_stopasgroup             = false,
  $program_killasgroup             = false,
  $program_user                    = 'root',
  $program_redirect_stderr         = undef,
  $program_stdout_logfile          = undef,
  $program_stdout_logfile_maxbytes = undef,
  $program_stdout_logfile_backups  = undef,
  $program_stdout_capture_maxbytes = undef,
  $program_stdout_events_enabled   = undef,
  $program_stderr_logfile          = undef,
  $program_stderr_logfile_maxbytes = undef,
  $program_stderr_logfile_backups  = undef,
  $program_stderr_capture_maxbytes = undef,
  $program_stderr_events_enabled   = undef,
  $program_environment             = undef,
  $program_directory               = undef,
  $program_umask                   = undef,
  $program_conf_persmissions       = '0644',
  $program_conf_backup             = true,
  $program_serverurl               = undef,) {
  # Include supervisor if not.
  if !defined(Class['supervisor']) {
    include supervisor
  }

  $supervisor_package_name = $supervisor::params::supervisor_package_name
  $supervisor_service_name = $supervisor::params::supervisor_service_name
  $supervisor_conf_dir     = $supervisor::params::supervisor_conf_dir

  file { "${supervisor_conf_dir}/${name}.conf":
    ensure  => $ensure,
    backup  => $program_conf_backup,
    path    => "${supervisor_conf_dir}/${name}.conf",
    mode    => $program_conf_persmissions,
    content => template('supervisor/program.conf.erb'),
    require => [Package[$supervisor_package_name], File[$supervisor_conf_dir]],
    notify  => Service[$supervisor_service_name],
  }

  exec { "supervisorctl restart ${name}":
    refreshonly => true,
    path => [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ]
  }
}
# EOF
