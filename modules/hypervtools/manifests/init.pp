# Class: hypervtools

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
