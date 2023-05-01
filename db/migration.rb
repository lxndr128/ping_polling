module Migration

  def self.run
    unless File.exists?('db/.migrated')
      DbClient.query('DROP TABLE ips, ip_stat_units;', true)
      DbClient.query(query)
      File.new("db/.migrated", "w")
    end
  end

  def self.query
    'CREATE TABLE ips
      (
        ip CHARACTER VARYING(39) PRIMARY KEY,
        ipv6 BOOLEAN DEFAULT false,
        enabled BOOLEAN DEFAULT true
      );
    CREATE TABLE ip_stat_units
      (
        id SERIAL PRIMARY KEY,
        ip CHARACTER VARYING(39),
        rtt REAL,
        created_at TIMESTAMP
      );'
  end
end