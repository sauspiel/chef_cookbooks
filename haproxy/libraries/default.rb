def haproxy_ssl_certificates_to_multi_crt_string(certificates)
  buffer = Array.new
  certificates.each do |cert|
    buffer << "crt #{@node[:ssl_certificates][:path]}/#{ssl_certificate_as_wildcard(cert)}_all_in_one.crt"
  end
  buffer.join(" ")
end
