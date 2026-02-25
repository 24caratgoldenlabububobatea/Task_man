# Changelog

## 2026-02-25
- Fixed segmentation fault in `cpu_process_info.cpp` constructor - corrected pointer cast for `host_processor_info()`
- Fixed Objective-C memory management in `Frontend.mm`:
  - Proper NSMutableArray initialization with `alloc/init`
  - Added null checks before accessing array elements in `drawRect:`
  - Set window delegate and made AppDelegate conform to `NSWindowDelegate`
  - Added timer cleanup in dealloc method
- Fixed CPU calculation logic to properly average across cores instead of summing (was inflating usage on multi-core systems)
- Replaced random dummy CPU values with real measurements from `CPUUsageMonitor` in `refreshCPU` method
- Added C++ CPU monitor instance to AppDelegate for actual CPU sampling
- Fixed include path for `process_info.h` in Frontend.mm
- App now displays realistic CPU usage without crashes

- Implementerte `CPUUsageMonitor` og fikset sampling-logikk (unngå doble kall)
- Laget `sampler/main.cpp` for å skrive ut CPU-målinger
- Lagt til `meow` test-verktøy for minne-stress
- Opprettet `README.md` og `TODO.md` for videre arbeid
- Opprettet `CHANGELOG.md`
- Bygget og testet kompilering (lokalt)

*(Følg formatet: dato og punktliste over endringer for hver dag)*
