#!/bin/sh

# Fetch Cloudflare IPs
curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips_v4
curl -s https://www.cloudflare.com/ips-v6 -o /tmp/cf_ips_v6

# Clear old rules
iptables -F
iptables -X

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow Cloudflare IPs for ports 80 and 443
echo "Allowing Cloudflare IPs for HTTP/HTTPS..."
for cfip in $(cat /tmp/cf_ips_v4); do
    iptables -A INPUT -p tcp -s "$cfip" --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp -s "$cfip" --dport 443 -j ACCEPT
done

for cfip in $(cat /tmp/cf_ips_v6); do
    ip6tables -A INPUT -p tcp -s "$cfip" --dport 80 -j ACCEPT
    ip6tables -A INPUT -p tcp -s "$cfip" --dport 443 -j ACCEPT
done

# Block all other access to ports 80 and 443
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP
ip6tables -A INPUT -p tcp --dport 80 -j DROP
ip6tables -A INPUT -p tcp --dport 443 -j DROP

# Save iptables rules for persistence
iptables-save | tee /etc/iptables/rules.v4
ip6tables-save | tee /etc/iptables/rules.v6


echo "Firewall rules updated successfully."
