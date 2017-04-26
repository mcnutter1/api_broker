#PLUGIN DECLARATION

my $_PLUGIN_NAME = "new_test_plugin";
my $_INITIATOR = "new_test_init";
my $_CALL_BACK = "new_test_cb";
my $_ACTIVE = 1;

main::activate_plugin({name=>$_PLUGIN_NAME, initiator=>$_INITIATOR, call_back=>$_CALL_BACK}) if $_ACTIVE eq 1;




sub new_test_cb {
        my $content = shift;
        return "hello world";
}




