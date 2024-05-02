class Rack::Attack
  class Request < ::Rack::Request
    # Create a remote_ip method for a rack request by setting it to the Cloudflare connecting ip header.
    # To restore original visitor IP addresses at your origin web server, Cloudflare recommends your logs or applications look at CF-Connecting-IP instead of X-Forwarded-For, since CF-Connecting-IP has a consistent format containing only one IP.
    # https://support.cloudflare.com/hc/en-us/articles/200170986-How-does-CloudFlare-handle-HTTP-Request-headers-
    def remote_ip
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] || ip).to_s
    end

    # This checks the request IP against the Cloudflare IP ranges and the action dispatch default trusted proxies.
    # These include various local IPs like 127.0.0.1 so that local requests won't be blocked.
    def proxied?
      Rails.application.config.action_dispatch.trusted_proxies.any? { |range| range === ip }
    end
  end

  # Block all requests coming from non-Cloudflare IPs.
  blocklist(" block non-proxied requests in production" ) do |request|
    if request.proxied?
      false
    else
      true if FEATURE_LIMIT_TO_CLOUDFLARE
    end
  end
end