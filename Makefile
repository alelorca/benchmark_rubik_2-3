#
# This file is part of rubik_2^3
# Copyright (C) 2008 Alejandro Lorca <alelorca@yahoo.es>
# 
# rubik_2^3 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# rubik_2^3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with rubik_2^3.  If not, see <http://www.gnu.org/licenses/>.
#
TARGET:=rubik_2x2x2
VERSION:=1.0
# For real equivalence to HEPSPEC06 (if used without static, multiply the obtained value by 1.037 and the error by 1.6)
CXXFLAGS=-O2 -fPIC -pthread --static
#CXXFLAGS=-O2 -fPIC -pthread -m32 --static
CXX=g++
OBJECTS:=run_rubik.o rubik.o
PACKAGE:=run_rubik.cpp rubik.cpp run_rubik.h Makefile README benchmark_rubik.pl benchmark.jdl

.PHONY: all clean

all: $(TARGET)

$(TARGET): run_rubik.o rubik.o
	$(CXX) $(CXXFLAGS) -o $@ $(OBJECTS)

%.o: %.cpp %.h
	$(CXX) $(CXXFLAGS) -c $< 

tgz: $(PACKAGE)
	cd ..; tar cpzf benchmark_rubik-$(VERSION).tgz $(addprefix benchmark_rubik-$(VERSION)/,$(PACKAGE)); cd benchmark_rubik-$(VERSION)

clean:
	rm -f *.o $(TARGET)
