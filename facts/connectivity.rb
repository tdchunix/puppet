# Fact: connectivity
#
# Purpose: Return true/false on access to various URLs
#
#
require 'net/https'
require 'uri'

# What to monitor
# the '/' at the URLs is import otherwise the URI.path is empty
urltomonitor = []
urltomonitor.push(
                  # Test access to redhat
                  {
                    'name'   => 'redhat',
                    'url'    => 'http://www.redhat.com/en',
                    'string' => 'Contact'
                  },
                  # Test access to redhat via a proxy
                  {
                    'name'       => 'foo_bar_proxy',
                    'url'        => 'http://www.redhat.com/en',
                    'string'     => 'Contact',
                    'proxy_host' => 'foo.bar.com',
                    'proxy_port' => '3128'
                  },
                  # Connectivity to a specific puppet server
                  {
                    'name'   => 'puppet_master',
                    'url'    => 'https://puppetmaster:8140/',
                    'string' => 'Powered by Jetty'
                  },

                  )

def checkconnection(name,url,string,proxy_host=nil,proxy_port=nil)
  # Checks that a connection to url on host:port returns the expected string
  begin
    # http timeout
    conntimeout = 3
    http = Net::HTTP.new(URI(url).host, URI(url).port, proxy_host, proxy_port)
    if ( URI(url).scheme == 'https' )
      http.use_ssl = true
      # Don't check SSL certs
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http.open_timeout = conntimeout
    res = http.get(URI(url).request_uri)

    (res.body.index(/.*#{string}.*/m)) ? (return "true") : (return "false")
  rescue Exception => err
    return "false"
  end
  return "false"
end

# To store the results
results = Hash.new

begin
  urltomonitor.each { |website|
    connectionstatus = checkconnection(website['name'],website['url'],website['string'],website['proxy_host'],website['proxy_port'])
    results[website['name']] = connectionstatus
  }
rescue Exception => err
    urltomonitor.each { |website|
      results[website['name']] = 'false'
    }
end

# Create the facts
results.keys.each{ |website|
  Facter.add("connectivity_"+website) do
    setcode do
      results[website]
    end
  end
}
