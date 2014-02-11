include_recipe "erlang::default"

['erlang-base-hipe','erlang-nox'].each { |pkg| package pkg }
