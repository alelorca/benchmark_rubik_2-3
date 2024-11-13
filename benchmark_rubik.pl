#!/usr/bin/env perl
########################################################################
#                                                                      #
#  Copyright 2011. Alejandro Lorca <alejandro.lorca@cti.csic.es>       #
#  <alejandro.lorca@computer.org>                                      #
#  IFCA/SGAI, Consejo Superior de Investigaciones Cientificas-CSIC     #
#                                                                      #
#  Licensed under the Apache License, Version 2.0 (the "License");     #
#  you may not use this file except in compliance with the License.    #
#  You may obtain a copy of the License at                             #
#                                                                      #
#  http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                      #
#  Unless required by applicable law or agreed to in writing, software #
#  distributed under the License is distributed on an "AS IS" BASIS,   #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or     #
#  implied. See the License for the specific language governing        #
#  permissions and limitations under the License.                      #
#                                                                      #
#  Project http://ghost.sgai.csic.es/redmine/projects/benchmark-rubik  #
#  Based on an own project Rubik_2^3, 2009                             #
#  Lightweight and fast Benchmark offering an estimation of the        #
#  HEPSPEC2006/core Benchmark                                          #
#                                                                      #
########################################################################

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;

# Version
my $code_version = '1.0';
my ($help, $version, $license, $debug, $quiet);

# The getoptions parses the cli
GetOptions('help' => \$help, 'version' => \$version, 'license' => \$license, 'debug' => \$debug, 'quiet' => \$quiet);

Print_usage(0) if $help;
Print_version() if $version;
Print_license() if $license;


# Preparing the execution
my $hostname = hostname();
Print_debug("Preparing the execution of the benchmark rubik in host $hostname, may take few minutes...");
my $executable = './rubik_2x2x2';
if ( ! -e $executable and -e 'Makefile' ){
	Print_debug("The binary $executable does not exist yet, running make");
	system('make', '-s') == 0 or die "The binary $executable could not be made";
}
my $format = '%e;%U;%S;%E;%P;%M;%x';

# Running the command exchanging stderr and stdout
my $exchange = defined $quiet ? '2>&1 1>/dev/null' : '3>&1 1>&2 2>&3 3>&-';
my $command = `/usr/bin/env time --format="$format" $executable -c -q 15 $exchange`;
Print_debug($format);
Print_debug($command);

# Opening the result
my ($e, $u, $s, @trash) = split (/;/, $command);

# The Benchmark formula for equivalence to HEPSPEC06/core
# $HEPSPEC06_core = coefficient / elapsed_time, where coef = 729 and err_coef = 9, according to the last fit

my $coef = Get_coefficients();
my $coef_value = $coef->[0];
my $coef_error = $coef->[1];
my $HEPSPEC06_core = $coef_value / $e;
my $HEPSPEC06_core_error_sist =  $coef_error / $e;
my $HEPSPEC06_core_error_stat =  $coef_value / ( $e * $e ) * abs( $e - $u - $s );
my $HEPSPEC06_core_error = $HEPSPEC06_core_error_sist + $HEPSPEC06_core_error_stat;
$HEPSPEC06_core = Truncate ($HEPSPEC06_core);
$HEPSPEC06_core_error = Truncate ($HEPSPEC06_core_error);

# The output
print "HOSTNAME=$hostname;HEPSPEC_core=$HEPSPEC06_core;HEPSPEC_core_error=$HEPSPEC06_core_error;USER=$u;ELAPSED=$e;SYSTEM=$s\n";
########################################################################
#                                                                      #
#   Sub Get_coefficient                                                #
#                                                                      #
########################################################################
sub Get_coefficients{
	my @coef=(729,9);
	return \@coef;
}
########################################################################
#                                                                      #
#   Sub Print_usage                                                    #
#                                                                      #
########################################################################
sub Print_version{
	Print_output("Benchmark Rubik, an estimation of HEPSPEC06/core, version $code_version");
	exit;
}
########################################################################
#                                                                      #
#   Sub Print_license                                                  #
#                                                                      #
########################################################################
sub Print_license{
        Print_output('Copyright 2011, Alejandro Lorca <alejandro.lorca@cti.csic.es>
IFCA/SGAI, Consejo Superior de Investigaciones Cientificas.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.');
	exit;
}
########################################################################
#                                                                      #
#   Sub Print_usage                                                    #
#   argument: exit status                                              #
#                                                                      #
########################################################################
sub Print_usage{
        my $exit_status = shift;
	Print_output('Usage: benchmark_rubik.pl [OPTION]');
	if (! $exit_status){
		Print_output('
 OPTIONS:
      --debug             Debugging information
      --quiet             Do not print Rubik_2^3 output
 HELP and ABOUT:
  -v, --version           Version number of the programme.
  -l, --license           Credits and license.
  -h, --help              Print this help.');
	}
	else {
		Print_output('type subcommand -h for help');
	}
	exit $exit_status;
}
########################################################################
#                                                                      #
#   Sub Print_output                                                   #
#                                                                      #
########################################################################
sub Print_output{
	my $output_message = shift;
	print STDOUT "$output_message\n";
}
########################################################################
#                                                                      #
#   Sub Print_debug                                                    #
#                                                                      #
########################################################################
sub Print_debug{
        my $output_message = shift;
	my $date = localtime();
        print STDERR "[DEBUG, $date]: $output_message\n" if defined $debug;
}
########################################################################
#                                                                      #
#   Sub Truncate                                                       #
#   argument: exit status                                              #
#                                                                      #
########################################################################
sub Truncate {
	my $value = shift;
	return int($value*100 + .5 * ($value <=> 0))/100;
}
