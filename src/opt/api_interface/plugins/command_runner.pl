#PLUGIN DECLARATION

my $_PLUGIN_NAME = "command_runner_plugin";
my $_INITIATOR = "command";
my $_CALL_BACK = "command_runner_cb";
my $_ACTIVE = 1;

main::activate_plugin({name=>$_PLUGIN_NAME, initiator=>$_INITIATOR, call_back=>$_CALL_BACK}) if $_ACTIVE eq 1;
##END DECLARATION

my @ALLOWED_COMMANDS = ('dir', 'df -h', 'sleep 5', 'sleep');

sub command_runner_cb {
        my $content = shift;
        my %response;
        print Dumper($content);
                                        $i=0;
                                        foreach my $entry (@$content){
                                                $i++;
                                                my $command = $entry->{content};
                                                if ( grep( /^$command$/, @ALLOWED_COMMANDS)) {
                                                        $flags = $entry->{flags};
                                                        print $flags;
                                                        print "Executing command $command\n";
                                                        $output = `$command $flags`;
                                                        $response{"Command Request $i"}{command} = [$command];
                                                        $response{"Command Request $i"}{status} = ["success"];
                                                        if ($entry->{output} eq 1) {
                                                                $response{"Command Request $i"}{output} = [$output];
                                                        }
                                                } else {
                                                        print "Bad command: $command\n";
                                                        $response{"Command Request $i"}{command} = [$command];
                                                        $response{"Command Request $i"}{status} = ["failure"];
                                                }
                                        }


        return \%response;
}

