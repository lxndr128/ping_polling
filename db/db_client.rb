require 'pg'
require 'async'

class DbClient
  def self.query(string, async=false)
    result = []
    PG::Connection.async_api = async
    Async { result = request(string) } if async
    result = request(string) unless async
    result.to_a
  end

  private

  def self.request(string)
    client = PG::Connection.new(
      host:     'db',
      dbname: ENV['POSTGRES_DB'],
      password: ENV['POSTGRES_PASSWORD'],
      user: ENV['POSTGRES_USER']
    )
    result = client.exec_params(string)
  end
end
