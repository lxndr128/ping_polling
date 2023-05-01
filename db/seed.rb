require_relative 'queries'
require_relative 'db_client'

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

DbClient.query('DROP TABLE ips, ip_stat_units;')
DbClient.query(Queries.migration)
File.new("db/.migrated", "w")

ips.each do |ip|
  DbClient.query(Queries.add_ip(ip))
end
