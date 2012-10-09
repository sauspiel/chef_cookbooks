def as_nginx_deny_cmd(infile, outfile)
  return "cat #{infile} | sed \'s/255\\.255\\.255\\.255,//g\' | sed -E \'s/([0-9.]*),?/deny \\1;/g\' > #{outfile}"
end
