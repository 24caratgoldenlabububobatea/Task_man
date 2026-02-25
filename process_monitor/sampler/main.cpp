#include <iostream>
#include <thread>
#include <chrono>

#include "system/process_info.h"

int main() {
    CPUUsageMonitor cpu;

    while (true) {
        double usage = cpu.sample();
        if (usage == 0) {
            std::cout << "Error sampling CPU usage\n";
        } else {
            std::cout << "CPU Usage: " << usage << "%\n";
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}
