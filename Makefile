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
URL=https://github.com/alelorca/rubik_2-3.git
TARGETDIR:=rubik_2^3
TARGET:=rubik_2^3/rubik_2^3
VERSION:=1.3
# For real equivalence to HEPSPEC06 (if used without static, multiply the obtained value by 1.037 and the error by 1.6)
CXXFLAGS=-O2 -fPIC -pthread --static
CXX=g++
OBJECTS:=run_rubik.o rubik.o
PACKAGE:=Makefile README benchmark_rubik.pl

.PHONY: all clean

all: $(TARGETDIR) $(TARGET)

$(TARGETDIR):
	git clone $(URL) $(TARGETDIR)

$(TARGET):
	@$(MAKE) -C $(@D)

%.o: %.cpp %.h
	$(CXX) $(CXXFLAGS) -c $<

tgz: $(PACKAGE)
	cd ..; tar cpzf benchmark_rubik-$(VERSION).tgz $(addprefix benchmark_rubik-$(VERSION)/,$(PACKAGE)); cd benchmark_rubik-$(VERSION)

clean:
	rm -rfv *.o $(TARGET) bin $(TARGETDIR)
