def ssl_certificate_as_wildcard(name)
  certname = name =~ /\*\.(.+)/ ? "#{$1}_wildcard" : name
  certname
end
