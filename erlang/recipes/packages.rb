include_recipe "erlang::default"

['erlang-base-hipe','erlang-nox', 'erlang-dev'].each { |pkg| package pkg }
