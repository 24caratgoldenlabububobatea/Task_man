// how to run: clang++ -std=c++11 -fPIC -c system/cpu_process_info.cpp -o cpu_process_info.o && clang++ -std=c++11 -framework Cocoa cpu_process_info.o ui/Frontend.mm -o CPUApp
#import <Cocoa/Cocoa.h>
#include "../system/process_info.h"

#define MAX_POINTS 100 // max points in graph

@interface CPUGraphView : NSView
@property (nonatomic, strong) NSMutableArray<NSNumber *> *points;
@end

@implementation CPUGraphView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _points = [[NSMutableArray alloc] initWithCapacity:MAX_POINTS];
        [self setWantsLayer:YES];
        if (self.layer) {
            self.layer.borderColor = [[NSColor whiteColor] CGColor];
            self.layer.borderWidth = 2.0;
            self.layer.cornerRadius = 4.0;
        }
    }
    return self;
}

- (void)addPoint:(double)value {
    if (self.points.count >= MAX_POINTS) {
        [self.points removeObjectAtIndex:0];
    }
    [self.points addObject:@(value)];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);

    if (!self.points || self.points.count < 2) return;

    [[NSColor greenColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat step = width / (MAX_POINTS - 1);

    NSNumber *firstPoint = self.points[0];
    if (!firstPoint) return;
    
    [path moveToPoint:NSMakePoint(0, height * [firstPoint doubleValue] / 100.0)];
    for (NSInteger i = 1; i < self.points.count; i++) {
        NSNumber *pointNum = self.points[i];
        if (!pointNum) continue;
        double value = [pointNum doubleValue];
        [path lineToPoint:NSMakePoint(i * step, height * value / 100.0)];
    }
    [path stroke];
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (strong) NSWindow *window;
@property (strong) NSButton *refreshButton;
@property (strong) NSTextField *cpuLabel;
@property (strong) CPUGraphView *graphView;
@end

@implementation AppDelegate {
    NSTimer *updateTimer;
    CPUUsageMonitor *cpuMonitor;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    cpuMonitor = new CPUUsageMonitor();
    
    NSRect frame = NSMakeRect(0, 0, 400, 300);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"CPU Monitor"];
    [self.window setDelegate:self];

    // Label text
    NSTextField *labelText = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 260, 300, 20)];
    [labelText setStringValue:@"CPU Usage:"];
    [labelText setBezeled:NO];
    [labelText setDrawsBackground:NO];
    [labelText setEditable:NO];
    [labelText setFont:[NSFont systemFontOfSize:14]];
    [[self.window contentView] addSubview:labelText];

    // CPU value label
    self.cpuLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 280, 300, 30)];
    [self.cpuLabel setEditable:NO];
    [self.cpuLabel setBezeled:NO];
    [self.cpuLabel setDrawsBackground:NO];
    [self.cpuLabel setFont:[NSFont boldSystemFontOfSize:24]];
    [self.cpuLabel setStringValue:@"0.00%"];
    [[self.window contentView] addSubview:self.cpuLabel];

    // Graph
    self.graphView = [[CPUGraphView alloc] initWithFrame:NSMakeRect(20, 50, 360, 180)];
    [[self.window contentView] addSubview:self.graphView];

    // Refresh button
    self.refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(150, 10, 100, 30)];
    [self.refreshButton setTitle:@"Refresh"];
    [self.refreshButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.refreshButton setTarget:self];
    [self.refreshButton setAction:@selector(refreshCPU)];
    [[self.window contentView] addSubview:self.refreshButton];

    [self.window makeKeyAndOrderFront:nil];

    // Safe auto-refresh with dummy values
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(refreshCPU)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)refreshCPU {
    // Get actual CPU usage from monitor
    if (cpuMonitor) {
        double usage = cpuMonitor->sample();

        if (self.cpuLabel) {
            [self.cpuLabel setStringValue:[NSString stringWithFormat:@"%.2f%%", usage]];
        }
        if (self.graphView) {
            [self.graphView addPoint:usage];
        }
    }
}

- (void)dealloc {
    if (updateTimer) {
        [updateTimer invalidate];
    }
    if (cpuMonitor) {
        delete cpuMonitor;
    }
}

// Quit app when window closes
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}