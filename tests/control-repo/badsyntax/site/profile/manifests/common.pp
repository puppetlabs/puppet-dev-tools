class profile::common {
  include profile::pe_env
  include profile::firewall

  case BAD SYNTAX $::osfamily {
    default: { } # for OS's not listed, do nothing
  }
}
