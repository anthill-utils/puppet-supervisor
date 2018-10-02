# == Class: supervisor::params
#
# This is a container class holding default parameters for supervisor module.
#
class supervisor::params {
  $supervisor_package_name      = 'supervisor'
  $supervisor_service_name      = 'supervisord'
  $supervisor_log_dir           = '/var/log/supervisor'
  $supervisor_etc_dir           = '/etc/supervisor'
  $supervisor_conf_dir          = '/etc/supervisor/conf.d'
  $supervisor_sysconfig         = '/etc/supervisor/supervisord.conf'
  $supervisor_sysconfig_options = ''
  $supervisor_logrotate         = '/etc/logrotate.d/supervisor'
}
# EOF
