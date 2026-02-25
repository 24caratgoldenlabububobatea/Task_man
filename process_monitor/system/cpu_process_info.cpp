#include "process_info.h"

#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

// difference between two measurements
CPUUsageMonitor::CPUUsageMonitor()
    : prevCpuInfo(nullptr), prevCpuInfoCount(0) {

    // Give me CPU load statistics
    natural_t cpuCount;
    host_processor_info(
        mach_host_self(),
        PROCESSOR_CPU_LOAD_INFO,
        &cpuCount,
        (processor_info_array_t*)&prevCpuInfo,
        &prevCpuInfoCount
    );
}

// Free any allocated resources
CPUUsageMonitor::~CPUUsageMonitor() {
    if (prevCpuInfo) {
        vm_deallocate(
            mach_task_self(),
            reinterpret_cast<vm_address_t>(prevCpuInfo),
            prevCpuInfoCount * sizeof(integer_t)
        );
    }
}
// Sample CPU usage since last call
double CPUUsageMonitor::sample() {
    natural_t cpuCount;
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t cpuInfoCount;

// Get current CPU load statistics
    host_processor_info(
        mach_host_self(),
        PROCESSOR_CPU_LOAD_INFO,
        &cpuCount,
        &cpuInfo,
        &cpuInfoCount
    );

// Calculate CPU usage based on difference between current and previous measurements
    double totalUsed = 0.0;
    double totalTime = 0.0;
    int coreCount = 0;

    auto* prev = static_cast<integer_t*>(prevCpuInfo);
    auto* curr = static_cast<integer_t*>(cpuInfo);

    // Loop through each CPU core
    for (int i = 0; i < cpuCount; i++) {
        int idx = i * CPU_STATE_MAX;
        
        uint64_t user   = curr[idx + CPU_STATE_USER]   - prev[idx + CPU_STATE_USER];
        uint64_t system = curr[idx + CPU_STATE_SYSTEM] - prev[idx + CPU_STATE_SYSTEM];
        uint64_t nice   = curr[idx + CPU_STATE_NICE]   - prev[idx + CPU_STATE_NICE];
        uint64_t idle   = curr[idx + CPU_STATE_IDLE]   - prev[idx + CPU_STATE_IDLE];

        uint64_t used = user + system + nice;
        uint64_t total = used + idle;

        if (total > 0) {
            totalUsed += used;
            totalTime += total;
            coreCount++;
        }
    }

    // Free old snapshot
    vm_deallocate( 
        mach_task_self(),
        reinterpret_cast<vm_address_t>(prevCpuInfo),
        prevCpuInfoCount * sizeof(integer_t)
    );

    // Store current snapshot
    prevCpuInfo = cpuInfo;
    prevCpuInfoCount = cpuInfoCount;

    // Return average across all cores
    return totalTime > 0.0 ? (totalUsed / totalTime) * 100.0 : 0.0;
}
