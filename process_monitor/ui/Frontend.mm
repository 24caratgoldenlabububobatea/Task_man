// how to run: clang++ -std=c++11 -fPIC -c system/cpu_process_info.cpp -o cpu_process_info.o && clang++ -std=c++11 -framework Cocoa cpu_process_info.o ui/Frontend.mm -o CPUApp
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#include "../system/process_info.h"

#define MAX_POINTS 100

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
@property (strong) NSButton *websiteButton;
@property (strong) NSButton *muteButton;
@property (strong) NSTextField *cpuLabel;
@property (strong) CPUGraphView *graphView;
@property (strong) NSSpeechSynthesizer *speech;
@property (strong) AVAudioPlayer *backgroundMusicPlayer;
@property (assign) BOOL isMuted;
@end

@implementation AppDelegate {
    NSTimer *updateTimer;
    CPUUsageMonitor *cpuMonitor;
    id keyMonitor;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    cpuMonitor = new CPUUsageMonitor();
    self.isMuted = NO;

    // --- Speech Setup ---
    self.speech = [[NSSpeechSynthesizer alloc] init];
    self.speech.voice = @"com.apple.speech.synthesis.voice.Alex";
    [self.speech setRate:170.0];
    self.speech.volume = 1.00; // set initial volume to max
    [self.speech startSpeakingString:
     @"Yo what is up guys, if you lowkey got eyes that work enough that you can see the screen, you can see press the website button to submit your cpu percentage for everyone to see. if you don't have eyes that work, you can also press the spacebar to open the website, and if you want to hear my voice again, please press the M key to unmute me. Enjoy!"];

    // --- Background Music Setup ---
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"musicvro" ofType:@"mp3"];
    if (musicPath) {
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        NSError *error = nil;
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        if (error) {
            NSLog(@"Error loading music: %@", error.localizedDescription);
        } else {
            self.backgroundMusicPlayer.numberOfLoops = -1; // loop indefinitely
            self.backgroundMusicPlayer.volume = 0.15; // set lower volume
            [self.backgroundMusicPlayer prepareToPlay];
            [self.backgroundMusicPlayer play];
        }
    }

    // --- Window Setup ---
    NSRect frame = NSMakeRect(0, 0, 400, 360);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"CPU Monitor"];
    [self.window setDelegate:self];

    // --- CPU Label ---
    NSTextField *labelText = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 300, 300, 20)];
    [labelText setStringValue:@"CPU Usage:"];
    [labelText setBezeled:NO];
    [labelText setDrawsBackground:NO];
    [labelText setEditable:NO];
    [labelText setFont:[NSFont systemFontOfSize:14]];
    [[self.window contentView] addSubview:labelText];

    self.cpuLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 320, 300, 30)];
    [self.cpuLabel setEditable:NO];
    [self.cpuLabel setBezeled:NO];
    [self.cpuLabel setDrawsBackground:NO];
    [self.cpuLabel setFont:[NSFont boldSystemFontOfSize:24]];
    [self.cpuLabel setStringValue:@"0.00%"];
    [[self.window contentView] addSubview:self.cpuLabel];

    // --- Graph View ---
    self.graphView = [[CPUGraphView alloc] initWithFrame:NSMakeRect(20, 100, 360, 180)];
    [[self.window contentView] addSubview:self.graphView];

    // --- Website Button ---
    self.websiteButton = [[NSButton alloc] initWithFrame:NSMakeRect(80, 40, 100, 30)];
    [self.websiteButton setTitle:@"Website"];
    [self.websiteButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.websiteButton setTarget:self];
    [self.websiteButton setAction:@selector(openWebsite)];
    [[self.window contentView] addSubview:self.websiteButton];

    // --- Mute Button ---
    self.muteButton = [[NSButton alloc] initWithFrame:NSMakeRect(220, 40, 100, 30)];
    [self.muteButton setTitle:@"Mute"];
    [self.muteButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.muteButton setTarget:self];
    [self.muteButton setAction:@selector(toggleMute)];
    [[self.window contentView] addSubview:self.muteButton];

    [self.window makeKeyAndOrderFront:nil];

    // --- CPU Update Timer ---
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(refreshCPU)
                                                 userInfo:nil
                                                  repeats:YES];

    // --- Key Monitor ---
    keyMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                                       handler:^NSEvent *(NSEvent *event) {

        NSString *chars = [event charactersIgnoringModifiers];

        if ([chars isEqualToString:@" "]) {
            [self openWebsite];
            return nil;
        }

        if ([[chars lowercaseString] isEqualToString:@"m"]) {
            [self toggleMute];
            return nil;
        }

        return event;
    }];
}

- (void)refreshCPU {
    if (!cpuMonitor) return;

    double usage = cpuMonitor->sample();
    [self.cpuLabel setStringValue:[NSString stringWithFormat:@"%.2f%%", usage]];
    [self.graphView addPoint:usage];
}

- (void)openWebsite {
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)toggleMute {
    self.isMuted = !self.isMuted;

    if (self.isMuted) {
        [self.speech stopSpeaking];
        [self.backgroundMusicPlayer pause]; // pause music
        [self.muteButton setTitle:@"Unmute"];
    } else {
        [self.muteButton setTitle:@"Mute"];
        [self.speech startSpeakingString:
         @"Yo what is up guys, if you lowkey got eyes that work enough that you can see the screen, you can see press the website button to submit your cpu percentage for everyone to see. if you don't have eyes that work, you can also press the spacebar to open the website, and if you want to hear my voice again, please press the M key to unmute me. Enjoy!"];
        [self.speech volume: 1.00]; 
        [self.backgroundMusicPlayer play]; // resume music
    }
}

- (void)dealloc {
    if (updateTimer) {
        [updateTimer invalidate];
    }
    if (cpuMonitor) {
        delete cpuMonitor;
    }
    if (keyMonitor) {
        [NSEvent removeMonitor:keyMonitor];
    }
}

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