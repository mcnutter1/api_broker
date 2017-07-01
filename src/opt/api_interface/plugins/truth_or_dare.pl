#PLUGIN DECLARATION

my $_PLUGIN_NAME = "truth_or_date_plugin";
my $_INITIATOR = "truth_or_dare";
my $_CALL_BACK = "truth_or_dare_cb";
my $_ACTIVE = 1;

main::activate_plugin({name=>$_PLUGIN_NAME, initiator=>$_INITIATOR, call_back=>$_CALL_BACK}) if $_ACTIVE eq 1;


my $question_DB = main::read_json_file("questions.json");

sub truth_or_dare_cb {
        my $content = shift;
	my $players_gender = undef;



	my %dares = %{$question_DB->{dares}};
	my @dares_array = keys(%dares);


	my $random_dare = $dares_array[rand(@dares_array)];
	return HandleDynamicValue($random_dare,$content);	
}


sub sort_players_by_gender {

	my $players = shift;
	
	my $gender_list;

	foreach my $player (keys (%{$players})) {
		$gender = $players->{$player}->{gender};
        	push @{$gender_list->{$gender}},$player;
	}
	return $gender_list;
}





sub HandleDynamicValue {
        my $template = shift;
	my $game_content = shift;
        $template =~ s/\{(.*?)\}/_handle_variable($1, $game_content)/eg;
        return $template;
}
sub _handle_variable {
        my $variable = shift;
	my $game_content = shift;

	my $gender_list = sort_players_by_gender($game_content->{players}->{player});
	
	## Handle Number Range
        if ($variable =~ m/(\d)-(\d)/) {
                my @range = split('-',$variable);
                $i1 = $range[0];
                $i2 = $range[1];
                $num = $i2 + int rand( $i1-$i2+1 );
                return "$num";
        }
	## Handle Letter Range
	## Handle random epoch timestamp
	if ($variable eq "random_epoch") {
		return time()-GetRandomNumberInRange({high=>'9286400',low=>'3600'})->{result};
        }
	if ($variable eq "RMP") {
	

		@male_array = @{$gender_list->{m}};
               	$random_male = $male_array[rand @male_array];
		return $random_male;
	}

	if ($variable eq "RFP") {


                @female_array = @{$gender_list->{f}};
                $random_female = $male_array[rand @female_array];
                return $random_female;
        }

	if ($variable eq "RMPS") { ## Random Male Players


                @male_array = @{$gender_list->{m}};
		$total_of_gender = scalar(@male_array);

		my $random_total = rand($total_of_gender );
		
		$i = 0;
		
		$final_string = "";
		
		while ($i < ($random_total -1)) {
			$final_string .= "$male_array[$i]";
			if ($random_total > 2 && ($random_total - $i) > 1) {

			$final_string .= ", ";
			} 
			$i++;
		}
		
		print $final_string .= " and $male_array[$random_total]";

		print $final_string;
                $random_male = $male_array[rand @male_array];
                return $final_string;
        }
}
