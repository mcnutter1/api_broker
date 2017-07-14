#PLUGIN DECLARATION

my $_PLUGIN_NAME = "truth_or_date_plugin";
my $_INITIATOR = "truth_or_dare";
my $_CALL_BACK = "truth_or_dare_cb";
my $_ACTIVE = 1;

main::activate_plugin({name=>$_PLUGIN_NAME, initiator=>$_INITIATOR, call_back=>$_CALL_BACK}) if $_ACTIVE eq 1;


my $question_DB;
my %used_questions;

sub load_questions {

	 $question_DB = main::read_json_file("questions.json");
}

load_questions();


sub truth_or_dare_cb {
        my $content = shift;
	my $players_gender = undef;


	if ($content->{'reload-questions'} eq "true") {
		load_questions();
		print "Reloading Questions\n";
	}

	my $actor = $content->{actor};

	my $game_level =$content->{game_options}->{game_level} || 5;

	my $actor_gender = $content->{players}->{player}->{$actor}->{gender};
	
	my $game_token = $content->{game_token};

	my $last_question = $content->{last_question};

	$used_questions{$game_token}{$last_question} = true if $last_question ne "";
	
	print $game_token;	


	return unless $actor_gender;
	
	my %response;


	my %dares = %{sort_questions_by_gender($question_DB->{dares})};
	my @dares_array = keys($dares{$actor_gender});


	
	my %questions = %{sort_questions_by_gender($question_DB->{questions})};
        my @questions_array = keys($questions{$actor_gender});

	

	## Get Random dares
	#my $random_dare = $dares_array[rand(@dares_array)];
	#my $random_question = $questions_array[rand(@questions_array)];
	my $random_dare;
	my $random_question;
	$random_dare = select_random_by_level($game_level, \%dares, $actor_gender);
	$random_question = select_random_by_level($game_level, \%questions, $actor_gender);


	print "Hit Random\n\n"	if ($used_questions{"$game_token"}{"$random_dare"} eq 'true');
	print "Hit Random\n\n"  if ($used_questions{"$game_token"}{"$random_question"} eq 'true');
	while ($used_questions{$game_token}{$random_dare} eq 'true') {
		print "Hit used dare, retrying";
		$random_dare = select_random_by_level($game_level, \%dares, $actor_gender);
	}	



	while ($used_questions{$game_token}{$random_question} eq 'true') {
                print "Hit used dare, retrying";
                $random_question = select_random_by_level($game_level, \%questions, $actor_gender);
        }		
	
	
	$response{"dare"} = $actor . ", " . HandleDynamicValue($random_dare,$content);	
	$response{"question"} = $actor . ", " . HandleDynamicValue($random_question,$content);
	

	$response{"dare_detail"} = $question_DB->{dares}->{$random_dare};
	$response{"question_detail"} = $question_DB->{questions}->{$random_question};

#	$used_questions{$game_token}{$response{"dare"}} = true;
#	$used_questions{$game_token}{$response{"question"}} = true;

#	print Dumper(\%used_questions);

	return \%response;
}	


sub select_random_by_level {
	
	my $level = shift;
	my $question_hashref = shift;
	my $actor_gender = shift;
	my $db_level;
	
	my @questions_array = keys($question_hashref->{$actor_gender});	

	my $random_question = $questions_array[rand(@questions_array)];


	$db_level = $question_hashref->{$actor_gender}->{$random_question}->{level};

	
	while ($db_level gt $level) {
		print "Selected level $db_level while game is set to $level";
		$random_question = $questions_array[rand(@questions_array)];		
		$db_level = $question_hashref->{$actor_gender}->{$random_question}->{level};
		print "Trying Again...";	
		
	}

	return $random_question;	
	
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

sub sort_questions_by_gender {

        my $questions = shift;

        my $question_by_gender;
	
	my %questions_hash = %{$questions};

        foreach my $question (keys (%questions_hash)) {
                $gender = $questions_hash{$question}{gender};
		$question_obj = $questions_hash{$question};
		if ($gender eq "either" || $gender eq "") {
			$question_by_gender->{'f'}->{$question} = $question_obj;
			$question_by_gender->{'m'}->{$question} = $question_obj;
		} else {
			$question_by_gender->{$gender}->{$question} = $question_obj
        	}
	}
        return $question_by_gender;
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
                $random_female = $female_array[rand @female_array];
                return $random_female;
        }

	if ($variable =~ /RMP(\d)/) {
		

		my $digit = $variable;
                $digit =~ s/[^.\d]//g;

		@male_array = @{$gender_list->{m}};
                $total_of_gender = scalar(@male_array);
		print Dumper(\@male_array);
                my $random_total = rand($total_of_gender );

                $i = 0;

                $final_string = "";

                $random_total++ if $random_total eq 1;
                while ($i < ($digit -1)) {
                        $final_string .= "$male_array[$i]";
                        if ($random_total > 2 && ($random_total - $i) > 1) {

                 	       $final_string .= ", ";
                        }
                        $i++;
                }

                $final_string .= " and $male_array[$digit]";

                print $final_string;
                $random_male = $male_array[rand @male_array];
                return $final_string;
	
	}

	if ($variable eq "RMPS") { ## Random Male Players


                @male_array = @{$gender_list->{m}};
		$total_of_gender = scalar(@male_array);

		my $random_total = rand($total_of_gender );
		
		$i = 0;
		
		$final_string = "";

		$random_total++ if $random_total eq 1;
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
