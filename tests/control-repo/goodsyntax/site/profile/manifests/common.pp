class profile::common {
  include profile::pe_env
  include profile::firewall

  case $::osfamily {
    default: { } # for OS's not listed, do nothing
    "redhat": {
      notify { "I found redhat": }
    }
  }
}
