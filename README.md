
# Benchmark Rubik_2^3

## Table of Contents

1. [Installation](#installation)
2. [Features](#features)
3. [Usage](#usage)
4. [Output](#output)
5. [References](#references)
6. [License](#license)

## Installation

### Pre-requisites
The code is based on perl, but in order to run it properly the system requires compiling 
the underlying benchmark engine (Rubik_2^3) which is based on c++.

Under a basic Ubuntu 24.04 Linux installation it will require:
 * make
 * g++
 * git
 * time (not the bash built-in but the package)

```bash
apt-get install make g++ git time
```

By default, the first run will indeed download and compile all necessary objects

### 
```bash
# Clone the repository
git clone https://github.com/alelorca/benchmark_rubik_2-3.git

# Navigate to the project directory
cd benchmark_rubik_2-3

# Run the code in quiet mode
./benchmark_rubik.pl --quiet
```

## Features
This tool is intended to provide a fast CPU benchmark, somewhat comparable to the HEPSPEC06 results.
Instead of running a commercial benchmark for hours, the code presented here runs in a couple of minutes
in current commercial hardware such as workstations or servers and also allows to check the scalability
of the system by running several simultaneous instances up to the amount of available logical CPUs.

The output is a CSV list of values which can easily be translated into a graph for comparison purposes.

The amount of RAM needed is around 400 MiB per instance.

## Usage

```bash
# Get the help
./benchmark_rubik.pl -h
``` 

In general is nice to either run in quiet mode or separate the stderr with the benchmarking engine output
from the benchmark results:
```bash
./benchmark_rubik.pl 2>rubik_2^3.log
```

If running im multi-threaded mode beware that the code will run multiple times:
 - 1 instance
 - 2 simultaneous instances
 - ...
 - N simultaneous instances (where N is the number or the logical CPUs in the system)
 - 2xN simultaneous instances
 - 4xN simultaneous instances
being the purpose of running over the amount of total CPUs the stress of the system under expected overload 
and check if the total equivalent HS06 result is stable.

```bash
./benchmark_rubik.pl --quiet --multi | tee benchmark_multi.csv
```

## Output
The values provided are trying to estimate an average of what the full HEPSPEC06 benchmark result would be. Indeed the calculation is very simple and just adjusts some coefficients to have similar values on target systems which were calibrated around 2008, now probably obsoletes. Nevertheless, we can just compare the output of several systems and get an idea about how powerful their CPUs are.

Let's consider the following result:
```./benchmark_rubik.pl --quiet
Hostname,N_threads,Total_HS06,Err_Total_HS06,Avg_HS06,Err_Avg_HS06,CPU(%)
1ca2fb1982f5,1,30.57,0.38,30.57,0.38,99
```
In this case, the single-threaded power of the CPU is 30.57 with an error of 0.38, being the units arbitrary but the greater the better (kind of inverse to the elapsed computing time). The CPU thread was running at 99% which is indicative if there was some other processes on the system using the CPU as well.

The multi option allows for inspection of several simultaneus runs. For example, in a system with 16 cores and 16 GiB of RAM one could expect such output:
```
Hostname,N_threads,Total_HS06,Err_Total_HS06,Avg_HS06,Err_Avg_HS06,CPU(%)
desktop,1,30.15,0.37,30.15,0.37,99
desktop,2,53.62,0.66,26.81,0.33,99
desktop,4,90.96,1.12,22.74,0.3,99
desktop,8,152.24,1.88,19.03,0.28,99
desktop,16,193.17,2.38,12.08,0.21,97.94
desktop,32,173.54,2.14,5.43,0.23,50.03
```
where the last run of 64 instances failed due to lack of memory with messages like this:
```bash
Argument "Command terminated by signal 9\n43.63" isn't numeric in division (/) at ./benchmark_rubik.pl line 234.
Thread 77 terminated abnormally: Illegal division by zero at ./benchmark_rubik.pl line 234.
```
Still, the output allows to understand that the best behaviour is when running 16 threads since the value of the Total_HS06 (193.17) is the highest.

## References 
1. HEPSPEC06: [https://w3.hepix.org/benchmarking/HS06.html]
2. Rubik_2^3: [https://github.com/alelorca/rubik_2-3/]

## License
This project is licensed under the Apache v2 License - see the LICENSE file for details.
