# Common profile class
class profile::common {
  include profile::pe_env
  include profile::firewall

  case $facts['os']['family'] {
    default: { } # for OS's not listed, do nothing
    'redhat': {
      notify { 'I found redhat': }
    }
  }
}
