def haproxy_ssl_certificates_to_multi_crt_string(certificates, opts = {})
  buffer = Array.new
  spdy = opts[:with_spdy] ? "npn spdy/2" : ""
  certificates.each do |cert|
    buffer << "ssl crt #{@node[:ssl_certificates][:path]}/#{ssl_certificate_as_wildcard(cert)}_all_in_one.crt #{spdy}"
  end
  buffer.join(" ")
end
