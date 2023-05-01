module Queries
  
  def self.add_ip(ip, ipv6=false, enabled=true)
    "INSERT INTO ips (ip, ipv6, enabled) VALUES ('#{ip}', #{ipv6}, #{enabled});"
  end

  def self.remove_ip(ip)
    "DELETE FROM ips WHERE ip = '#{ip}';"
  end

  def self.get_ips
    'SELECT ip, ipv6 FROM ips WHERE enabled = true;'
  end

  def self.enable_ip(ip)
    "UPDATE ips SET enabled = true WHERE ip = '#{ip}';"
  end

  def self.disable_ip(ip)
    "UPDATE ips SET enabled = false WHERE ip = '#{ip}';"
  end

  def self.add_stat_unit(ip: nil, rtt: nil, part:0)
    return "INSERT INTO ip_stat_units (ip, rtt, created_at) VALUES ('#{ip}', #{rtt}, '#{DateTime.now}');" if part == 0
    return "INSERT INTO ip_stat_units (ip, rtt, created_at) VALUES " if part == 1
    return " ('#{ip}', #{rtt}, '#{DateTime.now}')," if part == 2
  end

  def self.get_stat(ip, time_from, time_to)
    loss_ = loss(ip, time_from, time_to)
    median_ = median(ip, time_from, time_to)
    "SELECT AVG(rtt), MIN(rtt), MAX(rtt), STDDEV_SAMP(rtt) AS standard_deviation, #{median_} AS median, #{loss_} AS loss_percentage
     FROM ip_stat_units
     WHERE ip = '#{ip}' AND created_at BETWEEN '#{time_from}' AND '#{time_to}' AND rtt IS NOT NULL;"
  end

  def self.median(ip, time_from, time_to)
    "(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY rtt) 
      FROM ip_stat_units
      WHERE ip = '#{ip}' AND created_at BETWEEN '#{time_from}' AND '#{time_to}' AND rtt IS NOT NULL)"
  end

  def self.count(ip, time_from, time_to)
    "(SELECT COUNT(ip)
      FROM ip_stat_units
      WHERE ip = '#{ip}' AND created_at BETWEEN '#{time_from}' AND '#{time_to}')"
  end

  def self.loss(ip, time_from, time_to)
    count_ = count(ip, time_from, time_to)
    "(SELECT CASE COUNT(ip) WHEN 0 THEN 0 ELSE ROUND((COUNT(ip) / (#{count_} / 100.0)), 2) END
      FROM ip_stat_units
      WHERE ip = '#{ip}' AND created_at BETWEEN '#{time_from}' AND '#{time_to}' AND rtt IS NULL)"
  end
end