# ## A task to remove the Co-operative party from result summaries.
task :remove_cooperative_party_from_result_summaries => :environment do
  puts "removing the cooperative party from result summaries"
  
  # We know that the result summary with ID 21 is 'Conservative gain from Labour Co-operative' ...
  # ... and that the result summary with ID 13 is 'Conservative gain from Labour'.
  # We find any election with a result summary ID of 21.
  elections = Election.where( 'result_summary_id = ?', 21 )
  
  # For each election with a result summary ID of 21 ...
  elections.each do |election|
  
    # ... we set the result summary ID to 13 ...
    election.result_summary_id = 13
    
    # ... and save the election.
    election.save!
  end
  
  # We know that the result summary with ID 19 is 'SNP gain from Labour Co-operative' ...
  # ... and that the result summary with ID 3 is 'SNP gain from Labour'.
  # We find any election with a result summary ID of 19.
  elections = Election.where( 'result_summary_id = ?', 19 )
  
  # For each election with a result summary ID of 19 ...
  elections.each do |election|
  
    # ... we set the result summary ID to 3 ...
    election.result_summary_id = 3
    
    # ... and save the election.
    election.save!
  end
  
  # We find the result summary with ID 21 ...
  result_summary = ResultSummary.find ( 21 )
  
  # ... and destroy it.
  result_summary.destroy!
  
  # We find the result summary with ID 19 ...
  result_summary = ResultSummary.find ( 19 )
  
  # ... and destroy it.
  result_summary.destroy!
end

