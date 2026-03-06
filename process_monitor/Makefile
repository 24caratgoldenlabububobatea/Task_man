# Makefile for building the CPU monitor project with and without networking

CXX=clang++
CXXFLAGS=-std=c++17 -I.
LIBS=-pthread -lcurl

# Sources that are always compiled
COMMON_SRCS=system/cpu_process_info.cpp system/server.cpp

# Target without networking: uses plain main
monitor: $(COMMON_SRCS) sampler/main.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS)

# Target with networking: add network code and alternate main
monitor_net: $(COMMON_SRCS) system/network.cpp sampler/main_net.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS)

# Target for Cocoa GUI app
CPUApp: $(COMMON_SRCS) ui/Frontend.mm
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS) -framework Cocoa -framework AVFoundation

clean:
	rm -f monitor monitor_net CPUApp
