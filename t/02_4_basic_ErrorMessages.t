use Test::More tests => 15;
BEGIN { use_ok('IO::Capture::ErrorMessages') };

#Save initial values
my ($initial_stderr_dev, $initial_stderr_inum) = (stat(STDERR))[0,1];
my $warn_save = $SIG{__WARN__}; 

#Test 2
ok (my $capture = IO::Capture::ErrorMessages->new(), "Constructor Test");

#########################################################
# Start, put some data, stop ############################
#########################################################

my $rv1 = $capture->start() || 0;
my $rv2;
if ($rv1) {
    print STDERR "Test Line One";
    print STDERR "Test Line Two";
    warn "Test Line Three\n";
    print STDERR "Test Line Four";
    $rv2 = $capture->stop()  || 0;
}

#########################################################
# Check the results #####################################
#########################################################

#Test 3
ok ($rv1, "Start Method");

#Test 4
ok ($rv2, "Stop Method");

#Test 5
my $line1 = $capture->read();
my $results_line1 = $line1 eq "Test Line One";
ok ($results_line1, "Read Method, First Line");
diag "*"x60 . "\n1st line read was: $line1\n" . "*"x60 . "\n\n" unless $results_line1;

#Test 6
my $line2 = $capture->read();
my $results_line2 = $line2 eq "Test Line Two";
ok ($results_line2, "Read Method, Second Line");
diag "*"x60 . "\n2nd line read was: $line2\n" . "*"x60 . "\n\n" unless $results_line2;

#Test 7
my $line3 = $capture->read();
my $results_line3 = $line3 eq "Test Line Three\n";
ok ($results_line3, "Read Method, warn() Line");
diag "*"x60 . "\n3rd line read was: $line3\n" . "*"x60 . "\n\n" unless $results_line3;

#Test 8
my $line4 = $capture->read();
my $results_line4 = $line4 eq "Test Line Four";
ok ($results_line4, "Read Method, 4th Line");
diag "*"x60 . "\n4rd line read was: $line4\n" . "*"x60 . "\n\n" unless $results_line4;

#Test 9
$capture->line_pointer(1);
my $new_line = $capture->line_pointer;
ok($new_line == 1, "Check set line_pointer");

#Test 10
my $line1_2 = $capture->read();
my $results_line1_2 = $line1_2 eq "Test Line One";
ok ($results_line1_2, "Read After line_pointer(), First Line");
diag "*"x60 .
     "\nline read after line_pointer() was: $line1_2\n" .
     "*"x60 .
     "\n\n"
     unless $results_line1_2;

#Test 11
my @lines_array = $capture->read;
ok(@lines_array == 4, "List Context Check");

#########################################################
# Check for untie #######################################
#########################################################

#Test 12
my $tie_check = tied *STDERR;
ok(!$tie_check, "Untie Test");

#########################################################
# Check filehandles - STDERR ############################
#########################################################

my ($ending_stderr_dev, $ending_stderr_inum) = (stat(STDERR))[0,1];
#Test 13 
ok ($initial_stderr_dev == $ending_stderr_dev, "Invariant Check - STDERR filesystem dev number");

#Test 14
ok ($initial_stderr_inum == $ending_stderr_inum, "Invariant Check - STDERR inode number");

#########################################################
# Check WARN ############################################
#########################################################
#Test 15
my $test_result_13 = $SIG{__WARN__} eq $warn_save;
ok ($test_result_13, "Invariant Check - __WARN__");
diag "\n" . "*"x60 . "\n__WARN__ did not get restored correctly in $0\n" . "*"x60 . "\n\n" unless $test_result_13;
