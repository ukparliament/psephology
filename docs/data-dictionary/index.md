<html>
	<head>
		<title>Data dictionary</title>
		<meta name="description" content="A data dictionary for the UK Parliament election results website.">
	</head>
	<body>
		<h1>Data dictionary</h1>
		<div id="erd">
			<h2>Entity relationship diagram</h2>
			<a href="/schema.svg"><img id="schema" title="Database schema" src="/schema.svg" /></a>
		</div>

		<div id="tables">
			<h2>Tables</h2>
			<nav>
				<ol>
					<li><a href="#boundary_set_general_election_party_performances">boundary_set_general_election_party_performances</a></li>
					<li><a href="#boundary_set_legislation_items">boundary_set_legislation_items</a></li>
					<li><a href="#boundary_sets">boundary_sets</a></li>
					<li><a href="#candidacies">candidacies</a></li>
					<li><a href="#certifications">certifications</a></li>
					<li><a href="#commons_library_dashboard_countries">commons_library_dashboard_countries</a></li>
					<li><a href="#commons_library_dashboards">commons_library_dashboards</a></li>
					<li><a href="#constituency_area_overlaps">constituency_area_overlaps</a></li>
					<li><a href="#constituency_area_types">constituency_area_types</a></li>
					<li><a href="#constituency_areas">constituency_areas</a></li>
					<li><a href="#constituency_group_set_legislation_items">constituency_group_set_legislation_items</a></li>
					<li><a href="#constituency_group_sets">constituency_group_sets</a></li>
					<li><a href="#constituency_groups">constituency_groups</a></li>
					<li><a href="#countries">countries</a></li>
					<li><a href="#country_general_election_party_performances">country_general_election_party_performances</a></li>
					<li><a href="#elections">elections</a></li>
					<li><a href="#electorates">electorates</a></li>
					<li><a href="#enablings">enablings</a></li>
					<li><a href="#english_region_general_election_party_performances">english_region_general_election_party_performances</a></li>
					<li><a href="#english_regions">english_regions</a></li>
					<li><a href="#genders">genders</a></li>
					<li><a href="#general_election_in_boundary_sets">general_election_in_boundary_sets</a></li>
					<li><a href="#general_election_party_performances">general_election_party_performances</a></li>
					<li><a href="#general_elections">general_elections</a></li>
					<li><a href="#legislation_items">legislation_items</a></li>
					<li><a href="#legislation_types">legislation_types</a></li>
					<li><a href="#maiden_speeches">maiden_speeches</a></li>
					<li><a href="#members">members</a></li>
					<li><a href="#parliament_periods">parliament_periods</a></li>
					<li><a href="#political_parties">political_parties</a></li>
					<li><a href="#political_party_registrations">political_party_registrations</a></li>
					<li><a href="#result_summaries">result_summaries</a></li>
				</ol>
			</nav>
		</div>


		<div id="boundary_set_general_election_party_performances">
			<h2>boundary_set_general_election_party_performances</h2>
			<p>A denormalised table storing performances for a political party, in a general election, in a boundary set. Used to make <a href="https://electionresults.parliament.uk/boundary-sets/6/parties">boundary set general election party performance pages</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>constituency_contested_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies contested by candidates standing for a given political party in a given general election in a given boundary set. This is not used by the election results website, which only lists the number of constituencies won.</td>
						</tr>
						<tr>
							<td>constituency_won_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies won by candidates standing for a given political party in a given general election in a given boundary set.</td>
						</tr>
						<tr>
							<td>cumulative_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative vote count of all candidates standing for a given political party in a given general election in a given boundary set. This is not used by the election results website, which only lists the number of constituencies won.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Identifies the political party.</td>
						</tr>
						<tr>
							<td>boundary_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#boundary_sets">boundary_sets</a></td>
							<td>Identifies the boundary set.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="boundary_set_legislation_items">
			<h2>boundary_set_legislation_items</h2>
			<p>A join table linking a boundary set to the legislation establishing that boundary set. A boundary set may be established by one or more items of legislation. An item of legislation may be establish one or more boundary sets, or none.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>boundary_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#boundary_sets">boundary_sets</a></td>
							<td>Identifies the boundary set.</td>
						</tr>
						<tr>
							<td>legislation_item_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#legislative_items">legislative_items</a></td>
							<td>Identifies the legislative item.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="boundary_sets">
			<h2>boundary_sets</h2>
			<p>A boundary set defining UK Parliament constituency areas, as proposed in a boundary review by the Boundary Commissions and established by statute.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>start_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The start date of the boundary set. Boundary sets come into being on the date of dissolution of a Parliament. This value may be null, because we may know the details of a forthcoming boundary set, but not the date of dissolution and so not the start date of the boundary set.</td>
						</tr>
						<tr>
							<td>end_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The end date of the boundary set. Boundary sets end on the date of dissolution of a Parliament. This value may be null, because the date of dissolution is not known.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates the boundary set to the country to which that boundary set applies, being England, Northern Ireland, Scotland or Wales.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="candidacies">
			<h2>candidacies</h2>
			<p>A candidacy of a person standing in an election, for example: the candidacy of Philip Hammond standing as the Conservative Party candidate in Runnymede and Weybridge, at the 2015 general election. Also used to describe a candidacy of an unnamed candidate standing for a party in a notional election.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>candidate_given_name</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>The given name of a candidate standing in an election as it appears on the ballot paper. Given name is NULL for candidacies in a notional election.</td>
						</tr>
						<tr>
							<td>candidate_family_name</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>The family name of a candidate standing in an election as it appears on the ballot paper. Family name is NULL for candidacies in a notional election.</td>
						</tr>
						<tr>
							<td>candidate_is_sitting_mp</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the candidate was a sitting MP at the time of the election or a Member of Parliament in the Parliament preceding a general election.</td>
						</tr>
						<tr>
							<td>candidate_is_former_mp</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the candidate had been a sitting MP at any time prior to the election.</td>
						</tr>
						<tr>
							<td>is_standing_as_commons_speaker</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the candidacy is of the House of Commons Speaker standing for re-election to the House of Commons.</td>
						</tr>
						<tr>
							<td>is_standing_as_independent</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the candidacy is of a person standing as an independent, not being certified by any political party.</td>
						</tr>
						<tr>
							<td>is_notional</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the candidacy is a notional candidacy in a notional election forming part of a notional general election.</td>
						</tr>
						<tr>
							<td>result_position</td>
							<td>Integer</td>
							<td>Yes</td>
							<td></td>
							<td>The ordinal position of the result of a candidacy in an election, for example: 1st or 2nd, recorded as 1 or 2. Result positions are calculated when vote counts are confirmed and, for that reason, can be NULL. In practice all should be populated in any data release.</td>
						</tr>
						<tr>
							<td>is_winning_candidacy</td>
							<td>Integer</td>
							<td>Yes</td>
							<td></td>
							<td>Used to record the winning candidacy in an election. Winning candidacies are calculated when vote counts are confirmed and, for that reason, can be NULL. In practice all should be populated in any data release.</td>
						</tr>
						<tr>
							<td>vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of valid votes recorded for a candidacy.</td>
						</tr>
						<tr>
							<td>vote_share</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The calculated share of a vote won in an election by a candidacy as a proportion of the total valid votes. For example: Alex Baker receiving approximately 40.7% of the vote in the constituency of Aldershot in the 2019 general election.</td>
						</tr>
						<tr>
							<td>vote_change</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>The change in the vote share recorded for a candidacy in an election compared to the vote share for a candidacy in the same constituency at the previous general election, the previous candidacy either being certified by the same party - discounting any adjunct certification - or being of a candidate standing for re-election as the House of Commons Speaker, or being of the same person standing for re-election as an independent. The calculation of vote change does not take account of intervening by-elections. Where a constituency&#39;s boundary has changed since the last general election, the vote change figure is based on notional results, being projected results of the previous general election if that election had taken place according to new boundaries.</td>
						</tr>
						<tr>
							<td>candidate_gender_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#genders">genders</a></td>
							<td>Relates the candidacy to the gender of the candidate. This will be NULL for notional candidacies in a notional election taking place as part of a notional general election.</td>
						</tr>
						<tr>
							<td>election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#elections">elections</a></td>
							<td>Relates the candidacy to the election the candidacy formed part of.</td>
						</tr>
						<tr>
							<td>member_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#members">members</a></td>
							<td>Relates the candidacy to a Member record where the candidate has ever been a Member. This will be NULL for candidates who have never been a Member, and for notional candidacies in notional elections held as part of a notional general election.</td>
						</tr>
						<tr>
							<td>democracy_club_person_identifier</td>
							<td>Integer</td>
							<td>Yes</td>
							<td></td>
							<td>Used to record the Democracy Club identifier for the candidate. This will be NULL for notional candidacies in notional elections held as part of a notional general election.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="certifications">
			<h2>certifications</h2>
			<p>A certification of a candidate by a political party to stand in an election on behalf of that party. A candidate may be certified by more than one party at one time, for example: by both the Labour party and the Co-operative Party.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>candidacy_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#candidacies">candidacies</a></td>
							<td>Relates a certification to the candidacy being certified.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Relates a certification to the political party issuing the certification.</td>
						</tr>
						<tr>
							<td>adjunct_to_certification_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#certifications">certifications</a></td>
							<td>Relates a certification of a candidacy to another certification of the same candidacy to which the first certification is adjunct, for example: relating a Co-operative Party certification to a certification by the Labour party.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="commons_library_dashboard_countries">
			<h2>commons_library_dashboard_countries</h2>
			<p>A join table capturing the geographic extent of a House of Commons dashboard. Some dashboards cover constituencies in England and Wales; some cover constituencies in England, Wales and Scotland; some cover all constituencies in the UK.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>commons_library_dashboard_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#commons_library_dashboards">commons_library_dashboards</a></td>
							<td>Relates the geographic extent of a dashboard to that dashboard.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates the geographic extent of a dashboard to a country covered by that dashboard.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="commons_library_dashboards">
			<h2>commons_library_dashboards</h2>
			<p>A data dashboard published by the House of Commons Library.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>title</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The title of the data dashboard.</td>
						</tr>
						<tr>
							<td>url</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The URL of the data dashboard.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_area_overlaps">
			<h2>constituency_area_overlaps</h2>
			<p>Used to describe overlaps in area, number of residential properties or total population from a named geographic area to a succeeding or preceding named geographic area, for example: a UK Parliament constituency.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>from_constituency_residential</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of residential properties in the preceding geographic area forming part of the succeeding geographic area.</td>
						</tr>
						<tr>
							<td>to_constituency_residential</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of residential properties in the succeeding geographic area formed from part of the preceding geographic area.</td>
						</tr>
						<tr>
							<td>from_constituency_geographical</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of the area of the preceding geographic area forming part of the succeeding geographic area.</td>
						</tr>
						<tr>
							<td>to_constituency_geographical</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of the area of the succeeding geographic area formed from part of the preceding geographic area.</td>
						</tr>
						<tr>
							<td>from_constituency_population</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of the population of the preceding geographic area forming part of the succeeding geographic area.</td>
						</tr>
						<tr>
							<td>to_constituency_population</td>
							<td>Real number</td>
							<td>No</td>
							<td></td>
							<td>Used to record the proportion of the population in the succeeding geographic area formed from part of the preceding geographic area.</td>
						</tr>
						<tr>
							<td>from_constituency_area_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_areas">constituency_areas</a></td>
							<td>Relates a geographic area overlap to a directly preceding geographic area. A preceding area is an area which partly or wholly occupies the geography of its direct successor. A geographic area overlap relates to one preceding geographic area.</td>
						</tr>
						<tr>
							<td>to_constituency_area_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_areas">constituency_areas</a></td>
							<td>Relates a geographic area overlap to a directly succeeding geographic area. A succeeding area is an area which partly or wholly occupies the geography of its direct predecessor. A geographic area overlap relates to one succeeding geographic area.</td>
						</tr>
						<tr>
							<td>formed_from_whole_of</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record whether the whole of the preceding geographic area formed all or part of the succeeding geographic area, for example: the constituency area of Bangor Aberconwy being formed from the whole of the preceding constituency area of Aberconwy. The value of &#39;formed from whole of&#39; is true if the preceding area overlap value is 100%.</td>
						</tr>
						<tr>
							<td>forms_whole_of</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record whether the whole of the succeeding geographic area was formed from all or part of the preceding geographic area, for example: the constituency of Broadland and Fakenham forming the whole of the constituency area of Broadland. The value of &#39;forms whole of&#39; is true if the succeeding area overlap value is 100%.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_area_types">
			<h2>constituency_area_types</h2>
			<p>The type of a constituency area, being either county, borough or burgh.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>area_type</td>
							<td>Varchar(20)</td>
							<td>No</td>
							<td></td>
							<td>The label of the constituency area type.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_areas">
			<h2>constituency_areas</h2>
			<p>An area within which members of a constituency group are registered to vote. Constituency areas bounding constituency groups represented in the House of Commons are proposed in a boundary review by the Boundary Commissions and established by statute.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The name of the constituency area.</td>
						</tr>
						<tr>
							<td>geographic_code</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The code identifying the constituency area as a geographic entity.</td>
						</tr>
						<tr>
							<td>english_region_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#english_regions">english_regions</a></td>
							<td>Relates a constituency area to the English region it forms part of. NULL for constituency areas in Wales, Scotland and Northern Ireland.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates a constituency area to the country it forms part of, being England, Wales, Scotland or Northern Ireland.</td>
						</tr>
						<tr>
							<td>constituency_area_type_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_area_types">constituency_area_types</a></td>
							<td>Relates a constituency area to its type, being either county, borough or burgh.</td>
						</tr>
						<tr>
							<td>boundary_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#boundary_sets">boundary_sets</a></td>
							<td>Relates a constituency area to the boundary set which defines that area.</td>
						</tr>
						<tr>
							<td>mnis_id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>Relates a constituency area to its identifier in the <a href="https://data.parliament.uk/membersdataplatform/#">Members&#39; Names Information System</a>.</td>
						</tr>
						<tr>
							<td>is_geographic_code_issued_by_ons</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the geographic code for the constituency area was issued by the Office for National Statistics. The ONS has issued geographic codes for all recent constituencies across the UK. Prior to that, codes were only issued for constituencies in England and Wales only. Prior to that geographic codes were not issued. For that reason, the House of Commons Library has issued their own geographic codes for constituency areas lacking ONS issued codes.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_group_set_legislation_items">
			<h2>constituency_group_set_legislation_items</h2>
			<p>A join table linking a constituency group set to the legislation establishing that constituency group set. A constituency group set may be established by one or more items of legislation. An item of legislation may be establish one or more constituency group sets, or none.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>constituency_group_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_group_sets">constituency_group_sets</a></td>
							<td>Identifies the constituency group set.</td>
						</tr>
						<tr>
							<td>legislation_item_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#legislative_items">legislative_items</a></td>
							<td>Identifies the legislative item.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_group_sets">
			<h2>constituency_group_sets</h2>
			<p>A set of constituency groups, established by statute. Analogous to a boundary set, allowing for the grouping of constituencies with no geographic extent alongside constituencies with a geographic extent.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>start_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The start date of the constituency group set. Constituency group sets come into being on the date of dissolution of a Parliament. This value may be null, because we may know the details of a forthcoming constituency group set, but not the date of dissolution and so not the start date of the constituency group set.</td>
						</tr>
						<tr>
							<td>end_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The end date of the constituency group set. Constituency group sets end on the date of dissolution of a Parliament. This value may be null, because the date of dissolution is not known.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates the constituency group set to the country to which that constituency group set applies, being England, Northern Ireland, Scotland or Wales.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="constituency_groups">
			<h2>constituency_groups</h2>
			<p>A group of people represented by an election winner.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The name of the constituency group set.</td>
						</tr>
						<tr>
							<td>constituency_area_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#constituency_areas">constituency_areas</a></td>
							<td>Relates a constituency group to a geographic area. Some historical constituency groups had no defined geographical extent, for example: Oxford University. Since 1950, constituency groups represented in the House of Commons are within a constituency area. A new boundary set results in the creation of both a new constituency area and a new constituency group.</td>
						</tr>
						<tr>
							<td>constituency_group_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_group_sets">constituency_group_sets</a></td>
							<td>Relates a constituency group to the constituency group set of which it forms part.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="countries">
			<h2>countries</h2>
			<p>A country in the United Kingdom.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The name of the country.</td>
						</tr>
						<tr>
							<td>geographic_code</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>Relates a country to its geographic code.</td>
						</tr>
						<tr>
							<td>ons_linked</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the Office for National Statistics has a web page for the country, identified by the geographic code.</td>
						</tr>
						<tr>
							<td>parent_country_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates a country to its containing country.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="country_general_election_party_performances">
			<h2>country_general_election_party_performances</h2>
			<p>A denormalised table storing performances for a political party, in a general election, in a country. Used to make <a href="https://electionresults.parliament.uk/general-elections/4/countries/2">country-level general election party performance pages</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>

						<tr>
							<td>constituency_contested_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies contested by candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>constituency_won_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies won by candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>cumulative_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative vote count of all candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Identifies the political party.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Identifies the country.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="country_general_election_party_performances">
			<h2>country_general_election_party_performances</h2>
			<p>A denormalised table storing performances for a political party, in a general election, in a country. Used to make <a href="https://electionresults.parliament.uk/general-elections/4/countries/2">country-level general election party performance pages</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>

						<tr>
							<td>constituency_contested_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies contested by candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>constituency_won_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies won by candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>cumulative_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative vote count of all candidates standing for a given political party in a given general election in a given country.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Identifies the political party.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Identifies the country.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="elections">
			<h2>elections</h2>
			<p>An election to elect a person or persons to a seat or position.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>polling_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which polling takes place for an election.</td>
						</tr>
						<tr>
							<td>is_notional</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the election is notional, held as part of a notional general election.</td>
						</tr>
						<tr>
							<td>valid_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The total number of votes cast for all candidates in an election, excluding any votes declared invalid by the Returning Officer. Ballots issued and abandoned without being cast are not counted as votes cast. As of 2025, the Electoral Commission has published figures for the total number of votes cast calculated from the number of ballots issued, minus the number of invalid or spoiled ballots. The figures for the total number of votes cast published by the Electoral Commission include any ballots issued and abandoned without being cast.</td>
						</tr>
						<tr>
							<td>invalid_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of invalid votes - also called spoiled ballots - cast by an electorate in an election, for example: ballots on which votes are given for more candidates than the voter is entitled to vote for, ballots on which anything is written or marked by which the voter can be identified, or ballots which are unmarked or where a mark does not sufficiently identify the vote. The number of invalid votes may be included in a calculation of turnout. Turnout as calculated by the House of Commons Library - and generally in academic usage - is the total number of valid votes cast, divided by the size of the electorate. Turnout as calculated by a Returning Officer is the total number of votes cast, divided by the size of the electorate.</td>
						</tr>
						<tr>
							<td>majority</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The difference between the number of valid votes cast for the winning candidate and the number of valid votes cast for the second-placed candidate.</td>
						</tr>
						<tr>
							<td>declaration_at</td>
							<td>Timestamp</td>
							<td>Yes</td>
							<td></td>
							<td>The date and time at which results were declared for an election, for example: the date and time of the declaration of the results in a constituency election, by the Returning Officer.</td>
						</tr>
						<tr>
							<td>constituency_group_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_groups">constituency_groups</a></td>
							<td>Relates an election to the constituency group represented by the winner of that election.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Relates a constituency election held as part of a general election to that general election. A constituency election is related to one general election, or none in the case of a by-election.</td>
						</tr>
						<tr>
							<td>result_summary_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#result_summaries">result_summaries</a></td>
							<td>Relates an election to the textual summary of that election.</td>
						</tr>
						<tr>
							<td>electorate_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#electorates">electorates</a></td>
							<td>Relates an election to the group of people eligible to vote in that election. An election has one electorate. The same group of people forming an electorate may be eligible to vote in one or more elections over time, or none.</td>
						</tr>
						<tr>
							<td>parliament_period_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#parliament_periods">parliament_periods</a></td>
							<td>Relates an election to the House of Commons to the Parliament period within which any resulting incumbency takes place.</td>
						</tr>
						<tr>
							<td>writ_issued_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which the writ was issued for an election. For an election held as part of a general election, this is the date of dissolution of the preceding Parliament.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="electorates">
			<h2>electorates</h2>
			<p>A group of people eligible to vote in an election called at a particular time, for example: the group of people eligible to vote in an election to the House of Commons.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>population_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of people forming an electorate.</td>
						</tr>
						<tr>
							<td>constituency_group_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_groups">constituency_groups</a></td>
							<td>Relates an electorate to its constituency group.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="enablings">
			<h2>enablings</h2>
			<p>A join table linking an item of enabling legislation to an item of legislation enabled by that enabling legislation.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>enabling_legislation_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#legislation_items">legislation_items</a></td>
							<td>Identifies the enabling legislation.</td>
						</tr>
						<tr>
							<td>enabled_legislation_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#legislation_items">legislation_items</a></td>
							<td>Identifies the enabled legislation.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="english_region_general_election_party_performances">
			<h2>english_region_general_election_party_performances</h2>
			<p>A denormalised table storing performances for a political party, in a general election, in an English region. Used to make <a href="https://electionresults.parliament.uk/general-elections/4/countries/2/english-regions/3">general election party performance pages for an English region</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>constituency_contested_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies contested by candidates standing for a given political party in a given general election in a given English region.</td>
						</tr>
						<tr>
							<td>constituency_won_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies won by candidates standing for a given political party in a given general election in a given English region.</td>
						</tr>
						<tr>
							<td>cumulative_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative vote count of all candidates standing for a given political party in a given general election in a given English region.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Identifies the political party.</td>
						</tr>
						<tr>
							<td>english_region_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#english_regions">english_regions</a></td>
							<td>Identifies the English region.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="genders">
			<h2>genders</h2>
			<p>Genders.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>gender</td>
							<td>Varchar(20)</td>
							<td>No</td>
							<td></td>
							<td>The label assigned to the gender.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="general_election_in_boundary_sets">
			<h2>general_election_in_boundary_sets</h2>
			<p>Genders.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>ordinality</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The ordinality of the general election in a boundary set for example: the 2010 general election being the 1st general election held under the 2010-2024 boundary set for England.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>boundary_set_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#boundary_sets">boundary_sets</a></td>
							<td>Identifies the boundary set.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="general_election_party_performances">
			<h2>general_election_party_performances</h2>
			<p>A denormalised table storing performances for a political party, in a general election. Used to make <a href="https://electionresults.parliament.uk/general-elections/4">general election party performance pages</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>constituency_contested_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies contested by candidates standing for a given political party in a given general election.</td>
						</tr>
						<tr>
							<td>constituency_won_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of constituencies won by candidates standing for a given political party in a given general election.</td>
						</tr>
						<tr>
							<td>cumulative_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative vote count of all candidates standing for a given political party in a given general election.</td>
						</tr>
						<tr>
							<td>cumulative_valid_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative valid vote count of all candidates in all elections where one candidate was standing for a given political party in a given general election.</td>
						</tr>
						<tr>
							<td>general_election_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#general_elections">general_elections</a></td>
							<td>Identifies the general election.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Identifies the political party.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="general_elections">
			<h2>general_elections</h2>
			<p>A set of elections to the House of Commons, held concurrently in all constituencies.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>polling_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which polling takes place for all elections forming part of a general election.</td>
						</tr>
						<tr>
							<td>is_notional</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the results of a general election are notional. When a general election is contested on a new boundary set or boundary sets, notional results are calculated for the changed constituencies. Notional results are calculated as if the previous general election had been contested on the new boundaries. Notional winner and notional vote share are used to derive the party gain / hold and change in vote share information, respectively, at the subsequent general election.</td>
						</tr>
						<tr>
							<td>commons_library_briefing_url</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>The URL of the House of Commons Library briefing paper analysing the results of the general election.</td>
						</tr>
						<tr>
							<td>valid_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative valid vote count in all elections forming part of the general election.</td>
						</tr>
						<tr>
							<td>invalid_vote_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative invalid vote count in all elections forming part of the general election.</td>
						</tr>
						<tr>
							<td>electorate_population_count</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The cumulative population count of all electorates in all constituencies at the time of the general election.</td>
						</tr>
						<tr>
							<td>parliament_period_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#parliament_periods">parliament_periods</a></td>
							<td>Relates a general election to the Parliament period for which the general election is called.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="legislation_items">
			<h2>legislation_items</h2>
			<p>Items of legislation, being either Acts of Parliament or Orders in Council.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>title</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The title of the legislation item.</td>
						</tr>
						<tr>
							<td>uri</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>The non-information resource URI of the item of legislation on <a href="https://www.legislation.gov.uk/">legislation.gov.uk</a>. Some legislation pertinent to boundary changes is not yet published on legislation.gov.uk, so this field may be NULL.</td>
						</tr>
						<tr>
							<td>url_key</td>
							<td>Varchar(20)</td>
							<td>No</td>
							<td></td>
							<td>The URL key of the legislation item based on a similar pattern to <a href="https://www.legislation.gov.uk/">legislation.gov.uk</a>.</td>
						</tr>
						<tr>
							<td>made_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The date of making for an Order in Council. This field will be NULL if the legislation item is an Act of Parliament.</td>
						</tr>
						<tr>
							<td>royal_assent_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The date of Royal Assent for an Act of Parliament. This field will be NULL if the legislation item is an Order in Council.</td>
						</tr>
						<tr>
							<td>statute_book_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which the legislation item entered the statute book. For an Act of Parliament, this will be the date of Royal Assent. For an Order in Council, this will be the date of making.</td>
						</tr>
						<tr>
							<td>legislation_type_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#legislation_types">legislation_types</a></td>
							<td>Relates a legislation item to its type, being either an Act of Parliament or an Order in Council.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="legislation_types">
			<h2>legislation_types</h2>
			<p>An enumeration of legislation types, being Act of Parliament and Order in Council.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>label</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The label of the legislation type, being either &#39;Act of Parliament&#39; or &#39;Order in Council&#39;.</td>
						</tr>
						<tr>
							<td>abbreviation</td>
							<td>Varchar(20)</td>
							<td>No</td>
							<td></td>
							<td>The abbreviation of the legislation type, being either &#39;acts or &#39;orders&#39;.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="maiden_speeches">
			<h2>maiden_speeches</h2>
			<p>Maiden speeches made in the House of Commons.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>made_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which the maiden speech was made.</td>
						</tr>
						<tr>
							<td>session_number</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of the session in the Parliament.</td>
						</tr>
						<tr>
							<td>hansard_reference</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The Hansard reference for the maiden speech.</td>
						</tr>
						<tr>
							<td>url</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The URL for the maiden speech in Hansard.</td>
						</tr>
						<tr>
							<td>member_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#members">members</a></td>
							<td>Relates the maiden speech to the Member making that maiden speech.</td>
						</tr>
						<tr>
							<td>constituency_group_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#constituency_groups">constituency_groups</a></td>
							<td>Relates the maiden speech to the constituency group represented by the Member making that maiden speech.</td>
						</tr>
						<tr>
							<td>parliament_period_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#parliament_periods">parliament_periods</a></td>
							<td>Relates the maiden speech to the Parliament during which that maiden speech was made.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="members">
			<h2>members</h2>
			<p>Members of the House of Commons.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>given_name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The given name of the Member, as it appeared on a ballot paper.</td>
						</tr>
						<tr>
							<td>family_name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The family name of the Member, as it appeared on a ballot paper.</td>
						</tr>
						<tr>
							<td>mnis_id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The identifier for the Member taken from the <a href="https://data.parliament.uk/membersdataplatform/#">Members&#39; Names Information System</a>.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="parliament_periods">
			<h2>parliament_periods</h2>
			<p>The time period of a single Parliament between the date of its first assembly after a general election and its dissolution. A Parliament period contains contiguous session and prorogation periods. During a parliament period Parliament is either in session or prorogued. The start date of a Parliament may be changed by subsequent proclamations. A Parliament ends at the next dissolution. While the <a href="https://www.legislation.gov.uk/ukpga/2011/14/enacted">Fixed-term Parliaments Act 2011</a> was in force, the date of dissolution was determined by that Act or was named in a proclamation following a vote in Parliament for an early general election. The next Parliament began on the date named in the proclamation issued following a dissolution. Before the Fixed-term Parliaments Act 2011 came into force and after that Act was repealed by the <a href="https://www.legislation.gov.uk/ukpga/2022/11/contents">Dissolution and Calling of Parliament Act 2022</a>, the date of dissolution is fixed by proclamation. The dissolution proclamation also names the date for Parliament to reassemble. Parliament periods are the same across both Houses. Parliaments are numbered ordinally from the first Parliament of the United Kingdom, sitting in 1801.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>number</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The number of the Parliament in the set of Parliament&#39;s from 1801.</td>
						</tr>
						<tr>
							<td>summoned_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The date on which the Parliament was summoned.</td>
						</tr>
						<tr>
							<td>state_opening_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The date of the State Opening of Parliament. This might not be known at the point at which the date the Parliament is summoned is known so may be NULL.</td>
						</tr>
						<tr>
							<td>dissolved_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The date of dissolution of the Parliament. This will be NULL for the current Parliament.</td>
						</tr>
						<tr>
							<td>wikidata_id</td>
							<td>Varchar(20)</td>
							<td>Yes</td>
							<td></td>
							<td>The <a href="https://www.wikidata.org/wiki/Wikidata:Main_Page">Wikidata</a> ID of the Parliament.</td>
						</tr>
						<tr>
							<td>london_gazette</td>
							<td>Varchar(30)</td>
							<td>Yes</td>
							<td></td>
							<td>The issue number of the <a href="https://www.thegazette.co.uk/">London Gazette</a> in which the data of summons was published.</td>
						</tr>
						<tr>
							<td>commons_library_briefing_by_election_briefing_url</td>
							<td>Varchar(255)</td>
							<td>Yes</td>
							<td></td>
							<td>The URL of the Research Briefing analysing results of by-elections held during the Parliament.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="political_parties">
			<h2>political_parties</h2>
			<p>An organisation registered with the <a href="https://www.electoralcommission.org.uk/">Electoral Commission</a> as a political party. Political parties having undergone a major renaming - for example The Brexit Party and Reform UK - may have more than one record in this table, despite sharing an Electoral Commission registration.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>name</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The name of the political party, as registered with the Electoral Commission.</td>
						</tr>
						<tr>
							<td>abbreviation</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The abbreviation used to identify the political party.</td>
						</tr>
						<tr>
							<td>mnis_id</td>
							<td>Integer</td>
							<td>Yes</td>
							<td></td>
							<td>Relates a political party to its identifier in the <a href="https://data.parliament.uk/membersdataplatform/#">Members&#39; Names Information System</a>.</td>
						</tr>
						<tr>
							<td>has_been_parliamentary_party</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record whether a candidate standing for the political party has won an election during the time period covered by the <a href="https://electionresults.parliament.uk/">election results website</a>.</td>
						</tr>
						<tr>
							<td>disclaimer</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Disclaimer text for the political party. Used only to note that figures for candidates certified by both the Labour and Co-operative parties are listed under Labour.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="political_party_registrations">
			<h2>political_party_registrations</h2>
			<p>The registration of a political party in a country by the <a href="https://www.electoralcommission.org.uk/">Electoral Commission</a>.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>electoral_commission_id</td>
							<td>Varchar(20)</td>
							<td>No</td>
							<td></td>
							<td>The registration code of the political party with the Electoral Commission.</td>
						</tr>
						<tr>
							<td>start_on</td>
							<td>Date</td>
							<td>No</td>
							<td></td>
							<td>The start date of the registration period as published by the Electoral Commission.</td>
						</tr>
						<tr>
							<td>end_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The end date of the registration period as published by the Electoral Commission.</td>
						</tr>
						<tr>
							<td>political_party_name_last_updated_on</td>
							<td>Date</td>
							<td>Yes</td>
							<td></td>
							<td>The date on which the primary name of the political party was last updated with the Electoral Commission, as published by the Electoral Commission.</td>
						</tr>
						<tr>
							<td>political_party_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td>Relates the political party registration to the political party being registered.</td>
						</tr>
						<tr>
							<td>country_id</td>
							<td>Integer</td>
							<td>No</td>
							<td><a href="#countries">countries</a></td>
							<td>Relates the political party registration to the country the registration is in.</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>

		<div id="result_summaries">
			<h2>result_summaries</h2>
			<p>The textual summary of an election.</p>

			<div class="table-wrapper">
				<table>
					<thead>
						<tr>
							<td>Field name</td>
							<td>Field type</td>
							<td>Can be null?</td>
							<td>Foreign key to</td>
							<td>Description</td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>id</td>
							<td>Integer</td>
							<td>No</td>
							<td></td>
							<td>The primary key for the table.</td>
						</tr>
						<tr>
							<td>short_summary</td>
							<td>Varchar(50)</td>
							<td>No</td>
							<td></td>
							<td>The short summary of the election result, for example: &#39;Con gain from Lab&#39;.</td>
						</tr>
						<tr>
							<td>summary</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The expanded summary of the election result, for example: &#39;Conservative gain from Labour &#39;.</td>
						</tr>
						<tr>
							<td>summary</td>
							<td>Varchar(255)</td>
							<td>No</td>
							<td></td>
							<td>The expanded summary of the election result, for example: &#39;Conservative gain from Labour &#39;.</td>
						</tr>
						<tr>
							<td>is_from_commons_speaker</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the election result followed an election result where the House of Commons Speaker was the winning candidate.</td>
						</tr>
						<tr>
							<td>is_from_independent</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the election result followed an election result where the winning candidate stood as an independent.</td>
						</tr>
						<tr>
							<td>is_to_commons_speaker</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the election was won by a candidate standing as the House of Commons Speaker.</td>
						</tr>
						<tr>
							<td>is_to_independent</td>
							<td>Boolean</td>
							<td>No</td>
							<td></td>
							<td>Used to record if the election was won by a candidate standing as an independent.</td>
						</tr>
						<tr>
							<td>from_political_party_id</td>
							<td>Integer</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td></td>
							<td>Used to record the political party of the winner of the preceding election in that constituency, if any.</td>
						</tr>
						<tr>
							<td>to_political_party_id</td>
							<td>Integer</td>
							<td><a href="#political_parties">political_parties</a></td>
							<td></td>
							<td>Used to record the political party of the winner of the election, if any.</td>
						</tbody>
				</table>
			</div>
		</div>
	</body>
</html>