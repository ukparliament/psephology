class PopulateStateForGeneralElectionAndElection < ActiveRecord::Migration[8.1]
  def change
  
    # Remove unnecessary columns from general elections table.
    remove_column :general_elections, :is_map_available, :boolean
    remove_column :general_elections, :are_aggregations_available, :boolean
    
    puts "there"

    # Create the general election states table.
    create_table :general_election_states do |t|
      t.string :label
      t.integer :state
      t.timestamps
    end
    
    puts "here"
    
    # Add initial general election states.
    GeneralElectionState.create( label: 'Pre-candidates', state: 1 )
    GeneralElectionState.create( label: 'Candidates only', state: 2 )
    GeneralElectionState.create( label: 'Winners only', state: 3 )
    GeneralElectionState.create( label: 'Full results', state: 4 )
    
    # Associate all general elections with full results.
    add_column :general_elections, :general_election_state_id, :integer, :default => 4
    add_foreign_key :general_elections, :general_election_states
    
    # Create the election states table.
    create_table :election_states do |t|
      t.string :label
      t.integer :state
      t.timestamps
    end
  
    # Add initial election states.
    ElectionState.create( label: 'Pre-candidates', state: 1 )
    ElectionState.create( label: 'Candidates only', state: 2 )
    ElectionState.create( label: 'Winners only', state: 3 )
    ElectionState.create( label: 'Full results', state: 4 )
    
    # Associate all elections with full results.
    add_column :elections, :election_state_id, :integer, :default => 4
    add_foreign_key :elections, :election_states
  end
end

