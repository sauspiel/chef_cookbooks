def rails_with_logentries?(app, environment)
  use_logentries = true
  if !app["environments"][environment]["logentries"].nil?
    use_logentries = app["environments"][environment]["logentries"]
  end
  return use_logentries
end
