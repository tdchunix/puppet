# Class: hypervtools

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.


class hypervtools {
  if $::virtual == 'hyperv' {
    case $::operatingsystem {
      'RedHat', 'CentOS', 'OracleLinux', 'OEL': {
        if $::operatingsystemrelease in ['5.7','5.8','5.9','6.1','6.2','6.3'] {
          $HyperVToolsPackages = ['kmod-microsoft-hyper-v','microsoft-hyper-v-rhel']
          $PackagesToRemove    = ['hypervkvpd']
          $HyperVToolsServices = ['hypervkvpd']
        }
        elsif ($::operatingsystemrelease =~ /^5/) {
          fail('Unsupported operating system')
        }
        else {
          # > 6.4, using packages from RedHat
          $HyperVToolsPackages = ['hypervkvpd']
          $PackagesToRemove    = ['kmod-microsoft-hyper-v','microsoft-hyper-v-rhel']
          $HyperVToolsServices = ['hypervkvpd']
        }
      }
      'SLES': {
        $HyperVToolsPackages = ['hyper-v']
        $PackagesToRemove    = []
        $HyperVToolsServices = ['hv_kvp_daemon','hv_vss_daemon']
      }
      default: {
        fail('Unsupported operating system')
      }
    }

    package {$PackagesToRemove:
      ensure => absent,
    }
    package {$HyperVToolsPackages:
      ensure => installed,
    }
    service {$HyperVToolsServices:
      ensure  => running,
      enable  => true,
      require => Package[$HyperVToolsPackages],
    }
  }
  else {
    notice('This server is not running on Hyper-V.')
  }
}
