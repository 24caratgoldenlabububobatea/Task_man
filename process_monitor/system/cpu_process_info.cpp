#include "process_info.h"

#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

CPUUsageMonitor::CPUUsageMonitor()
    : prevCpuInfo(nullptr), prevCpuInfoCount() {

    natural_t cpuCount;
    host_processor_info(
        mach_host_self(),
        PROCESSOR_CPU_LOAD_INFO,
        &cpuCount,
        reinterpret_cast<processor_info_array_t*>(&prevCpuInfo),
        &prevCpuInfoCount
    );
}

CPUUsageMonitor::~CPUUsageMonitor() {
    if (prevCpuInfo) {
        vm_deallocate(
            mach_task_self(),
            reinterpret_cast<vm_address_t>(prevCpuInfo),
            prevCpuInfoCount * sizeof(integer_t)
        );
    }
}

double CPUUsageMonitor::sample() {
    natural_t cpuCount;
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t cpuInfoCount;

    host_processor_info(
        mach_host_self(),
        PROCESSOR_CPU_LOAD_INFO,
        &cpuCount,
        &cpuInfo,
        &cpuInfoCount
    );

    double used = 0.0;
    double total = 0.0;

    auto* prev = static_cast<integer_t*>(prevCpuInfo);
    auto* curr = static_cast<integer_t*>(cpuInfo);

    for (int idx = 0; idx < cpuCount * CPU_STATE_MAX; idx += CPU_STATE_MAX) {
        uint64_t user   = curr[idx + CPU_STATE_USER]   - prev[idx + CPU_STATE_USER];
        uint64_t system = curr[idx + CPU_STATE_SYSTEM] - prev[idx + CPU_STATE_SYSTEM];
        uint64_t nice   = curr[idx + CPU_STATE_NICE]   - prev[idx + CPU_STATE_NICE];
        uint64_t idle   = curr[idx + CPU_STATE_IDLE]   - prev[idx + CPU_STATE_IDLE];

        used  += user + system + nice;
        total += user + system + nice + idle;
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

    return total > 0.0 ? (used / total) * 100.0 : 0.0;
}
