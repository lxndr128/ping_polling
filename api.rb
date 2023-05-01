require 'sinatra'
require "sinatra/reloader"
require_relative 'db/db_client'
require_relative 'db/queries'
require_relative 'lib/handle_params'

set :raise_errors, false
set :show_exceptions, false

register Sinatra::Reloader if ENV['RACK_ENV'] == 'development'

before do
  content_type :json
  @params = HandleParams.call(request.params, request.fullpath.split('/')[2])
end

error do 
  { message: env['sinatra.error'].message }.to_json
end

post '/ips' do
  @params['enabled'] ||= true
  ipv6 = IPAddress.valid_ipv6?(@params['ip'])
  result = DbClient.query(Queries.add_ip(@params['ip'], ipv6, @params['enabled']))
  { success: true }.to_json
end

post '/ips/:id/enable' do
  DbClient.query(Queries.enable_ip(@params['id']))
  { enabled: true }.to_json
end

post '/ips/:id/disable' do
  DbClient.query(Queries.disable_ip(@params['id']))
  { disabled: true }.to_json
end

get '/ips/:id/stats' do
  @params['time_from'] ||= DateTime.new(1970, 1, 1)
  @params['time_to'] ||= DateTime.new(2170, 1, 1)
  result = DbClient.query(Queries.get_stat(@params['id'], @params['time_from'], @params['time_to']))[0]
  raise 'No data!' if result["min"].nil? && result["loss_percentage"] == '0'

  result.to_json
end

delete '/ips/:id' do
  DbClient.query(Queries.remove_ip(@params['id']))
  { deleted: true }.to_json
end