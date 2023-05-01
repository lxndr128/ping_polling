require 'async'
require 'async/semaphore'
require_relative 'db/db_client'
require_relative 'db/queries'

class Ping
  def initialize
    migrate

    while true do
      @resulting_query = Queries.add_stat_unit(part: 1)
      ips = DbClient.query(Queries.get_ips)
      Async do
        limit = Async::Semaphore.new(ENV['LIMIT_OF_CONCURRENT_REQUESTS'].to_i)
        ips.each do |ip|
          limit.async do
            take_result(`ping#{ipv6?(ip)} -c 1 -w 1 #{ip['ip']}`, ip['ip'])
          end
        end
      end
      Async do
        Async { sleep ENV['POLLING_FREQUENCY'].to_i }
        Async { DbClient.query(@resulting_query.chop + ';', true) if ips[0] }
      end
    end
  end

  private

  def ipv6?(ip)
    return ip['ipv6'] == 't' ? '6' : ''
  end

  def take_result(stdout, ip)
    rtt = stdout.split('/')[3]
    rtt = rtt[6..-1] if rtt
    rtt = 'NULL' unless rtt
    @resulting_query += Queries.add_stat_unit(ip:, rtt:, part: 2)
  end

  def migrate
    unless File.exists?('db/.migrated')
      DbClient.query(Queries.migration)
      File.new("db/.migrated", "w")
    end
  end 
end