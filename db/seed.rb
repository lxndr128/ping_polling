require_relative 'db_client'
require_relative 'migration'
require_relative 'queries'

def ips
  [ '173.245.59.106', 
    '112.199.61.104', 
    '185.69.149.2', 
    '185.69.149.97', 
    '108.162.192.13',
    '51.77.192.106', 
    '54.95.235.194',
    '39.96.153.51',
    '31.25.98.210',
    '31.25.98.169' ]
end

Migration.run

ips.each do |ip|
  DbClient.query(Queries.add_ip(ip))
end
