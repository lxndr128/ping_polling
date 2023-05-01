require "ipaddress"

class HandleParams
  def self.call(params, id)
    params['id'] = id if id
    params.keys.each do |key|
      case key
      when 'ip', 'id' then params[key] = handle_id(params[key])
      when 'enabled' then params[key] = handle_bool(params[key])    
      when 'time_from', 'time_to' then params[key] = handle_datetime(params[key])
      else raise 'Unknown params!'
      end
    end
    params
  end

  private

  def self.handle_datetime(datetime)
    DateTime.parse(datetime)
  end

  def self.handle_bool(bool)
    return true if bool == 'true'
    return false if bool == 'false'
    raise "Invalid boolean value '#{bool}'!"
  end

  def self.handle_id(ip)
    return ip if IPAddress.valid_ipv6?(ip) || IPAddress.valid_ipv4?(ip)
    raise "Invalid ip '#{ip}'!"
  end
end