# vim600: set syn=perl :
use strict;
use Test::More tests => 1;

use IO::Capture::Stdout;
use IO::Capture::ErrorMessages;

my $out_capture = IO::Capture::Stdout->new();
my $err_capture = IO::Capture::ErrorMessages->new();

$err_capture->start();
$out_capture->start();
$out_capture->stop();
$err_capture->stop();

ok(!$err_capture->read(), "Test for no error if empty");
