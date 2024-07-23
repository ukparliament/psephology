require 'csv'

# We set the Parliament number.
PARLIAMENT_NUMBER_2024 = 59

# We set the polling date.
POLLING_ON_2024 = '2024-07-04'

task :update_general_election_2024 => [
  :report_start_time,
  :generate_2024_cumulative_counts, # Because two electorate figures have changed.
  :report_end_time
]