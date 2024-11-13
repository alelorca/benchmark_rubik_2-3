
# Benchmark Rubik_2^3

## Table of Contents

1. [Installation](#installation)
2. [Features](#features)
3. [Usage](#usage)
4. [License](#license)

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

The amount of RAM needed is around 2GiB per instance.

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

## License
This project is licensed under the Apache v2 License - see the LICENSE file for details.
