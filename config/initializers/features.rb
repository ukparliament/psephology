# if FEATURE_LEVEL is test, or not set
if ENV.fetch('FEATURE_LEVEL', 'test') == 'test'
  FEATURE_SHOW_GENERAL_ELECTION_CARTOGRAMS = true
  FEATURE_SHOW_ELECTION_TIME_SERIES = true
# if FEATURE_LEVEL is set to something different
else
  FEATURE_SHOW_GENERAL_ELECTION_CARTOGRAMS = true
  FEATURE_SHOW_ELECTION_TIME_SERIES = false
end

FEATURE_FLAG_NO_RESULTS_YET=ActiveRecord::Type::Boolean.new.cast(ENV.fetch('FEATURE_FLAG_NO_RESULTS_YET', false))
FEATURE_LIMIT_TO_CLOUDFLARE=ActiveRecord::Type::Boolean.new.cast(ENV.fetch('FEATURE_LIMIT_TO_CLOUDFLARE', true))
