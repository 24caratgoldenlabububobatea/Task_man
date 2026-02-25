# Changelog

## 2026-02-25
### Bug Fixes & Critical Issues Resolved
- Fixed segmentation fault (exit code 139) in application startup
- Fixed critical pointer casting bug in `cpu_process_info.cpp` constructor:
  - Corrected `reinterpret_cast<processor_info_array_t*>(&prevCpuInfo)` to `(processor_info_array_t*)&prevCpuInfo`
  - Properly initialized `prevCpuInfoCount` to 0 instead of leaving uninitialized
- Fixed null pointer dereferences in `CPUGraphView::drawRect:` method causing crashes
- Fixed include path for `process_info.h` in Frontend.mm from `"system/process_info.h"` to `"../system/process_info.h"`

### Objective-C Memory Management Enhancements
- Replaced `[NSMutableArray array]` with explicit `[[NSMutableArray alloc] initWithCapacity:MAX_POINTS]` for proper memory initialization
- Added comprehensive null checks before accessing array elements in drawRect method
- Set window delegate and made AppDelegate conform to `NSWindowDelegate` protocol
- Implemented proper dealloc method with timer invalidation and CPUMonitor cleanup
- Fixed layer property access with null checks before modifying CALayer properties

### CPU Monitoring Features Implemented
- Integrated real-time CPU usage monitoring with `CPUUsageMonitor` class into UI
- Fixed CPU calculation algorithm to properly **average across cores** instead of summing raw values
  - Problem: On multi-core systems (e.g., 8-core), summing inflated values 8x
  - Solution: Calculate per-core usage and average for accurate reporting
- Replaced placeholder random dummy values (10-90%) with actual system CPU measurements from mach kernel
- Added `CPUUsageMonitor` C++ instance to AppDelegate for continuous real-time CPU sampling
- Implemented timer-based refresh mechanism: 1.0 second update interval for smooth graph animation

### User Interface & Visualization Improvements
- CPUGraphView displays real-time CPU usage as green line graph on black background with white border
- Graph window rolls left as new data points arrive (circular buffer with MAX_POINTS = 100)
- CPU percentage label updates with 2 decimal precision display (e.g., "42.35%")
- Window maintains proper focus and updates responsively without UI lag
- Added visual styling: border color, border width, and corner radius for modern appearance

### Compilation & Build System
- Successfully compiled CPUApp with C++11 standard and macOS Cocoa framework
- Two-stage build process:
  1. Compile C++ CPU monitor: `clang++ -std=c++11 -fPIC -c system/cpu_process_info.cpp -o cpu_process_info.o`
  2. Link with Objective-C++ UI: `clang++ -std=c++11 -framework Cocoa cpu_process_info.o ui/Frontend.mm -o CPUApp`
- Builds without errors, only minor Objective-C warnings

### Testing & Validation
- Tested app stability - runs without crashes for extended periods
- Verified CPU usage reporting is realistic and responsive to actual system load
- Confirmed graph updates smoothly without visual artifacts
- Validated proper cleanup on application termination

### Files Modified
- `system/cpu_process_info.cpp`: Fixed constructor, optimized core averaging algorithm
- `ui/Frontend.mm`: Integrated C++ CPU monitor, improved Objective-C++ memory management
- `CHANGELOG.md`: Comprehensive documentation of all changes

## 2026-02-02
- Flyttet CPU-måleklasse til `system/cpu_process_info.cpp`
- Implementerte `CPUUsageMonitor` og fikset sampling-logikk (unngå doble kall)
- Laget `sampler/main.cpp` for å skrive ut CPU-målinger
- Lagt til `meow` test-verktøy for minne-stress
- Opprettet `README.md` og `TODO.md` for videre arbeid
- Opprettet `CHANGELOG.md`
- Bygget og testet kompilering (lokalt)

*(Følg formatet: dato og punktliste over endringer for hver dag)*
