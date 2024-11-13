#!/usr/bin/env perl
########################################################################
#                                                                      #
#  Copyright 2011. Alejandro Lorca <alelorca@yahoo.es>                 #
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
#  Project https://github.com/alelorca/benchmark_rubik_2-3             #
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
my $code_version = '1.3';
my ($help, $version, $license, $debug, $quiet, $single, $multi, $noheader, $output);

# The getoptions parses the cli
GetOptions('help' => \$help, 'version' => \$version, 'license' => \$license, 'debug' => \$debug, 'quiet' => \$quiet, 'single' => \$single, 'multi' => \$multi, 'noheader' => \$noheader, 'output=s' => \$output);

Print_usage(0) if $help;
Print_version() if $version;
Print_license() if $license;


# Preparing the execution
my $hostname = hostname();
Print_debug("Preparing the execution of the benchmark rubik in host $hostname, may take few minutes...");
my $executable = 'rubik_2^3/rubik_2^3';
if ( ! -e $executable and -e 'Makefile' ){
	Print_debug("The binary $executable does not exist yet, running make");
	system('make', '-s') == 0 or die "The binary $executable could not be made";
}


# Running the command exchanging stderr and stdout
my $outputfile = defined $output ? $output : '/dev/null';
my $exchange = defined $quiet ? "2>&1 1>$outputfile" : '3>&1 1>&2 2>&3 3>&-';


Threaded_runs();

########################################################################
#                                                                      #
#   Sub Get_processors                                                 #
#                                                                      #
########################################################################
sub Get_processors {
	my $max_proc = `/bin/grep ^processor /proc/cpuinfo | wc -l`;
        chomp($max_proc);
	Print_debug("Found $max_proc processing units");
	return $max_proc;	
}
########################################################################
#                                                                      #
#   Sub Get_processor_runs                                             #
#                                                                      #
########################################################################
sub Get_processor_runs {
# This subroutine returns an array of integers which make sense in order
# to run several times a benchmarking with different simultaneous threads
	my $max_proc = Get_processors();
	my @proc_array;
	for (my $proc = 4*$max_proc; $proc != 0; $proc = int($proc/2)){
		push(@proc_array, $proc);
	}
	return reverse @proc_array;
}
########################################################################
#                                                                      #
#   average                                                            #
#                                                                      #
########################################################################
#http://andrewstechhints.blogspot.com.es/2010/02/standard-deviation-in-perl.html
sub average {
        my (@values) = @_;

        my $count = scalar @values;
        my $total = 0; 
        $total += $_ for @values; 

        return $count ? $total / $count : 0;
}
########################################################################
#                                                                      #
#   stddev                                                             #
#                                                                      #
########################################################################
#http://andrewstechhints.blogspot.com.es/2010/02/standard-deviation-in-perl.html
sub std_dev {
        my ($average, @values) = @_;

        my $count = scalar @values;
        my $std_dev_sum = 0;
        $std_dev_sum += ($_ - $average) ** 2 for @values;

        return $count ? sqrt($std_dev_sum / $count) : 0;
}
########################################################################
#                                                                      #
#   Print threaded result header                                       #
#                                                                      #
########################################################################
sub  Print_threaded_result_header{
        print "Hostname,N_threads,Total_HS06,Err_Total_HS06,Avg_HS06,Err_Avg_HS06,CPU(%)\n";
}
########################################################################
#                                                                      #
#   Build threaded result                                              #
#                                                                      #
########################################################################
sub Build_threaded_result {
	use List::Util qw( min max );
	my $n_thr = scalar @_;
	# Simple way, make an average of HEPSPECS
	my @avg_array;
	my @err_array;
	my @e_array;
        my $u_sum = 0;
        my $s_sum = 0;
	my @cpu_array;
	foreach (@_){
	  	push(@avg_array, $_->{HEPSPEC_core});
		push(@err_array, $_->{HEPSPEC_core_error});
		push(@e_array, $_->{ELAPSED});
                $u_sum += $_->{USER};
                $s_sum += $_->{SYSTEM};
		push(@cpu_array, $_->{CPU});
	}
	my $e_avg = average(@e_array);
	my $e_stddev = std_dev($e_avg, @e_array);
	Print_debug("Avg(elapsed)=$e_avg, Std_dev(elapsed)=$e_stddev");
	my ($total, $total_err) = Get_HEPSPEC06($n_thr, $e_avg, $e_stddev, $u_sum, $s_sum);
	my $average = Truncate(average(@avg_array));
	my $average_stddev = Truncate(std_dev($average, @avg_array));
        # Cuadrature sum of syst + stat. errors
	my $average_err = Truncate(sqrt($average_stddev * $average_stddev + max(@err_array)*max(@err_array)));
	my $cpu_percentage = Truncate(average(@cpu_array));
	print "$hostname,$n_thr,$total,$total_err,$average,$average_err,$cpu_percentage\n";
}
########################################################################
#                                                                      #
#   Sub Threaded_runs                                                  #
#                                                                      #
########################################################################
sub Threaded_runs {
	my @threaded_result_array;
	my @runs;
	if ( defined $multi ){
		use threads;
		@runs = Get_processor_runs();
        }
        elsif (defined $single) {
		@runs = (1);
	}
	else {
	# Default behaviour is to run in parallel with so many threads as procs
		@runs = (1);
	}
	unless ($noheader){
		Print_threaded_result_header();
	}
	foreach my $run (@runs){
		my @threaded_result_run;
		Print_debug("Running simultaneously on $run threads...");
		my @threads_run;
		for (my $thr_id=0; $thr_id!=$run; $thr_id++){
			my $thr = threads->create(sub{Run_rubik()});
			push(@threads_run, $thr);
		}
		# Let us wait for the results
		foreach (@threads_run){
			push(@threaded_result_run, $_->join());
		}
		push(@threaded_result_array, Build_threaded_result(@threaded_result_run));
	}
}
########################################################################
#                                                                      #
#   Sub Run_rubik                                                      #
#                                                                      #
########################################################################
sub Run_rubik{
	my $format = '%e;%U;%S;%P';
	my $command_string = qq(/usr/bin/env time --format="$format" $executable);
	if (defined $output){
		$command_string .= qq( -o $output);
	}
	else {
		$command_string .= qq( -c);
	}
	$command_string .= qq( -q 15 $exchange);
	Print_debug("Ready to execute: $command_string");
#	my $randsleep = 1 + rand(1);
	my $command = `$command_string`;
	Print_debug($format);
	chomp($command);
	Print_debug($command);
	# Opening the result
	my ($e, $u, $s, $cpu_percentage) = split (/;/, $command);
	chop($cpu_percentage);
	my ($HEPSPEC06_core, $HEPSPEC06_core_error) = Get_HEPSPEC06(1, $e, $u, $s);
	# The output
	my %result = (HOSTNAME => $hostname, HEPSPEC_core => $HEPSPEC06_core, HEPSPEC_core_error => $HEPSPEC06_core_error, USER=> $u, ELAPSED => $e, SYSTEM=>$s, CPU => $cpu_percentage);
	return \%result;
}
########################################################################
#                                                                      #
#   Sub Get_coefficient                                                #
#                                                                      #
########################################################################
sub Get_HEPSPEC06{
	my ($n, $e, $e_stddev, $u, $s) = @_;
#	print "$n, $e, $u, $s\n";
	my $coef = Get_coefficients();
        my $coef_value = $coef->[0];
        my $coef_error = $coef->[1];
        my $HEPSPEC06 = $n * $coef_value / $e;
        my $HEPSPEC06_error_sist = $n * $coef_error / $e;
	my $HEPSPEC06_error_stat = $n * $coef_value / ($e*$e) * $e_stddev;
	my $HEPSPEC06_error = sqrt($HEPSPEC06_error_sist*$HEPSPEC06_error_sist + $HEPSPEC06_error_stat*$HEPSPEC06_error_stat);
	return (Truncate($HEPSPEC06), Truncate($HEPSPEC06_error_sist));
}
########################################################################
#                                                                      #
#   Sub Get_coefficient                                                #
#                                                                      #
########################################################################
sub Get_coefficients{
	# The Benchmark formula for equivalence to HEPSPEC06/core
	# $HEPSPEC06_core = coefficient / elapsed_time, where coef = 729 and err_coef = 9, according to the last fit
	my @coef=(729,9);
	return \@coef;
}
########################################################################
#                                                                      #
#   Sub Print_usage                                                    #
#                                                                      #
########################################################################
sub Print_version{
	Print_output("Benchmark Rubik_2^3, an estimation of HEPSPEC06/core, version $code_version");
	exit;
}
########################################################################
#                                                                      #
#   Sub Print_license                                                  #
#                                                                      #
########################################################################
sub Print_license{
        Print_output('Copyright 2011,2014,2024 Alejandro Lorca <alelorca@yahoo.es>

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
	Print_output('Usage: benchmark_rubik.pl [OPTIONS]');
	if (! $exit_status){
		Print_output('
 OPTIONS:
      --single            Run only one instance (default)
      --multi             Run it multiple times in multithreaded mode for scalability
      --noheader          Do not print header line
      --output=FILE       Generate result file for Rubik_2^3 configuration universe
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
