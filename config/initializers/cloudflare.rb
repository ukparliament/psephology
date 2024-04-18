# These values should rarely or never change and Cloudflare should alert us before that happens.
# The list of GB Cloudflare proxy server IP ranges comes from https://www.cloudflare.com/en-gb/ips/
CLOUDFLARE_IP_RANGES = [IPAddr.new("103.21.244.0/22"),IPAddr.new("103.22.200.0/22"),IPAddr.new("103.31.4.0/22"),IPAddr.new("104.16.0.0/13"),IPAddr.new("108.162.192.0/18"),IPAddr.new("131.0.72.0/22"),IPAddr.new("141.101.64.0/18"),IPAddr.new("162.158.0.0/15"),IPAddr.new("172.64.0.0/13"),IPAddr.new("173.245.48.0/20"),IPAddr.new("188.114.96.0/20"),IPAddr.new("190.93.240.0/20"),IPAddr.new("197.234.240.0/22"),IPAddr.new("198.41.128.0/17"),IPAddr.new("104.24.0.0/14"),IPAddr.new("2405:8100::/32"),IPAddr.new("2405:b500::/32"),IPAddr.new("2606:4700::/32"),IPAddr.new("2803:f800::/32"),IPAddr.new("2a06:98c0::/29"),IPAddr.new("2c0f:f248::/32"),IPAddr.new("2400:cb00::/32")]

# By adding the Cloudflare IP ranges as trusted_proxies, Rails ignores those IPs when setting remote_ip and correctly sets it to the originating IP.
Rails.application.config.action_dispatch.trusted_proxies = CLOUDFLARE_IP_RANGES + ActionDispatch::RemoteIp::TRUSTED_PROXIES