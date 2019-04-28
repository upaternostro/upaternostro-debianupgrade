# Class: debianupgrade
# ===========================
#
# Full description of class debianupgrade here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'debianupgrade':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class debianupgrade (
  $from = $debianupgrade::params::from,
  $to   = $debianupgrade::params::to,
) inherits debianupgrade::params {
  Exec {
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', ],
  }

  exec { 'preupdate':
    command => 'apt-get update',
    timeout => 0,
    onlyif  => "grep ${from} /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null",
    notify  => Exec['preupgrade'],
  }

  exec { 'preupgrade':
    command     => 'apt-get -y -o Dpkg::Options::="--force-confold" upgrade',
    timeout     => 0,
    refreshonly => true,
    notify      => Exec['predistupgrade'],
  }

  exec { 'predistupgrade':
    command     => 'apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade',
    timeout     => 0,
    refreshonly => true,
    notify      => Exec['switchdist'],
  }

  exec { 'switchdist':
    command     => "sh -c \"for a in \`grep -l ${from} /etc/apt/sources.list /etc/apt/sources.list.d/*.list\`; do echo Patching \\\$a; sed -i 's/${from}/${to}/g' \\\$a; done\"",
    refreshonly => true,
    notify      => Exec['update'],
  }

  exec { 'update':
    command => 'apt-get update',
    timeout => 0,
    unless  => "grep ${from} /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null",
    notify  => Exec['upgrade'],
  }

  exec { 'upgrade':
    command     => 'apt-get -y -o Dpkg::Options::="--force-confold" upgrade',
    timeout     => 0,
    refreshonly => true,
    notify      => Exec['distupgrade'],
  }

  exec { 'distupgrade':
    command     => 'apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade',
    timeout     => 0,
    refreshonly => true,
  }

  notify { "Please reboot!":
    subscribe => Exec['distupgrade'],
  }
}
