# @summary
#   Defines members of `mod_proxy_balancer`
# 
# Sets up a balancer member inside a listening service configuration block in 
# the load balancer's `apache.cfg`.
#   
# This type will setup a balancer member inside a listening service
# configuration block in /etc/apache/apache.cfg on the load balancer.
# Currently it only has the ability to specify the instance name, url and an
# array of options. More features can be added as needed. The best way to
# implement this is to export this resource for all apache balancer member
# servers, and then collect them on the main apache load balancer.
#
# @note
#   Currently requires the puppetlabs/concat module on the Puppet Forge and
#   uses storeconfigs on the Puppet Server to export/collect resources
#   from all balancer members.
#
# @param name
#   The title of the resource is arbitrary and only utilized in the concat
#   fragment name.
#
# @param balancer_cluster
#   The apache service's instance name (or, the title of the apache::balancer
#   resource). This must match up with a declared apache::balancer resource.
#
# @param url
#   The url used to contact the balancer member server.
#
# @param options
#   Specifies an array of [options](https://httpd.apache.org/docs/current/mod/mod_proxy.html#balancermember) 
#   after the URL, and accepts any key-value pairs available to `ProxyPass`.
#
# @example
#   @@apache::balancermember { 'apache':
#     balancer_cluster => 'puppet00',
#     url              => "ajp://${::fqdn}:8009"
#     options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
#   }
#
define apache::balancermember (
  String $balancer_cluster,
  Stdlib::HTTPUrl $url = "http://${$facts['networking']['fqdn']}/",
  Array $options       = [],
) {
  concat::fragment { "BalancerMember ${name}":
    target  => "apache_balancer_${balancer_cluster}",
    content => inline_template(" BalancerMember ${url} <%= @options.join ' ' %>\n"),
  }
}
