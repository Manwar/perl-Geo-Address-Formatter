use strict;
use lib 'lib';
use feature qw(say);
use Test::More;
use Test::Exception;
use Data::Dumper;
use File::Basename qw(basename dirname);
use File::Spec;
use File::Find::Rule;
use File::Slurp;
use YAML qw(LoadFile);

use utf8;
# nicer output for diag and failures, see
# http://perldoc.perl.org/Test/More.html#CAVEATS-and-NOTES
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";


my $path = dirname(__FILE__) . '/testcases1';

my @files = File::Find::Rule->file()->name( '*.yaml' )->in( $path );

ok(scalar(@files), 'found at least one file');

my $CLASS = 'Geo::Address::Formatter';
use_ok($CLASS);

my $conf_path = dirname(__FILE__) . '/test_conf1';
my $GAF = $CLASS->new( conf_path => $conf_path );



sub _one_testcase {
  my $country    = shift;
  my $rh_testcase = shift;
  is(
    $GAF->format_address($rh_testcase->{components}),
    $rh_testcase->{expected},
    $country . ' - ' . $rh_testcase->{description}
  );
}



foreach my $filename (@files){
  my $country = basename($filename);
  $country =~ s/\.\w+$//; # us.yaml => us

  my @a_testcases = ();
  lives_ok {
    @a_testcases = LoadFile($filename);
  } "parsing file $filename";

  foreach my $rh_testcase (@a_testcases){
    _one_testcase($country, $rh_testcase);
  }
}


done_testing();