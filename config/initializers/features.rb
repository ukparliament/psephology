FEATURE_LEVEL = 'test'

if FEATURE_LEVEL == 'test'
  FEATURE_LIMIT_TO_CLOUDFLARE = false
  FEATURE_SHOW_GENERAL_ELECTION_CARTOGRAMS = true
  FEATURE_SHOW_ELECTION_TIME_SERIES = true
  FEATURE_SHOW_GENERAL_ELECTION_ANCHOR_LINK_TO_CSV = false
  FEATURE_FLAG_NO_RESULTS_YET = true
else
  FEATURE_LIMIT_TO_CLOUDFLARE = true
  FEATURE_SHOW_GENERAL_ELECTION_CARTOGRAMS = true
  FEATURE_SHOW_ELECTION_TIME_SERIES = false
  FEATURE_SHOW_GENERAL_ELECTION_ANCHOR_LINK_TO_CSV = false
  FEATURE_FLAG_NO_RESULTS_YET = false
end