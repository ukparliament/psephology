# If the FEATURE_LEVEL is test, or not set ...
if ENV.fetch('FEATURE_LEVEL', 'test') == 'test'
  
  # ... we turn on election level time series visualisations.
  FEATURE_SHOW_ELECTION_TIME_SERIES = true

# Otherwise, if the FEATURE_LEVEL is set to something different ...
else
  
  # ... we turn off election level time series visualisations.
  FEATURE_SHOW_ELECTION_TIME_SERIES = false
end

# We set the feature flag for no results yet messaging according to the environment variable.
FEATURE_FLAG_NO_RESULTS_YET=ActiveRecord::Type::Boolean.new.cast(ENV.fetch('FEATURE_FLAG_NO_RESULTS_YET', false))

# We set the feature flag for limiting IP addresses to Cloudflare according to the environment variable.
FEATURE_LIMIT_TO_CLOUDFLARE=ActiveRecord::Type::Boolean.new.cast(ENV.fetch('FEATURE_LIMIT_TO_CLOUDFLARE', true))