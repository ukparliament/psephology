if Rails.env.production? && !ENV["SWITCH_OFF_RACK_ATTACK"]
  Rack::Attack.blocklist('CloudFlare WAF bypass') do |req|
    !req.cloudflare?
  end
end