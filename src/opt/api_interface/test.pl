my $variable = "{RMP3}";
my $digit = $variable;
                $digit =~ s/[^.\d]//g;
                print $digit;
