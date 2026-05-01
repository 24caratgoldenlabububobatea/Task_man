# Makefile for building the CPU monitor project with and without networking. Ai generated.

CXX=clang++
CXXFLAGS=-std=c++17 -I. -I/opt/homebrew/opt/mysql-client/include
LIBS=-pthread -L/opt/homebrew/opt/mysql-client/lib -lmysqlclient -lcurl

COMMON_SRCS=system/cpu_process_info.cpp system/server.cpp


monitor: $(COMMON_SRCS) sampler/main.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS)

monitor_net: system/cpu_process_info.cpp system/network.cpp sampler/main_net.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS)

CPUApp: $(COMMON_SRCS) ui/Frontend.mm
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LIBS) -framework Cocoa -framework AVFoundation

clean:
	rm -f monitor monitor_net CPUApp