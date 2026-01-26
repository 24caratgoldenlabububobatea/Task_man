#pragma once

class CPUUsageMonitor {
public:
    CPUUsageMonitor();
    ~CPUUsageMonitor();

    // Call this periodically to get CPU usage %
    double sample();

private:
    void* prevCpuInfo;
    unsigned int prevCpuInfoCount;
}; 
