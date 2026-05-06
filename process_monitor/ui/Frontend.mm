// ai_generated
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#include "../system/process_info.h"

static NSFont *dyslexicFont(CGFloat size) {
    NSFont *font = [NSFont fontWithName:@"OpenDyslexic3Regular" size:size];
    if (!font) {
        font = [NSFont fontWithName:@"Comic Sans MS" size:size];
    }
    if (!font) {
        font = [NSFont fontWithName:@"Verdana" size:size];
    }
    if (!font) {
        font = [NSFont boldSystemFontOfSize:size];
    }
    return font;
}

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

    if (self.points.count < 2) return;

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


// Custom window to capture keyboard
@interface KeyWindow : NSWindow
@property (nonatomic, assign) id keyDelegate;
@end

@implementation KeyWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)keyDown:(NSEvent *)event {

    NSString *chars = [event charactersIgnoringModifiers];

    if ([chars isEqualToString:@" "]) {

        if ([self.keyDelegate respondsToSelector:@selector(openWebsite)]) {
            [self.keyDelegate performSelector:@selector(openWebsite)];
        }
        return;
    }

    if ([[chars lowercaseString] isEqualToString:@"m"]) {

        if ([self.keyDelegate respondsToSelector:@selector(toggleMute)]) {
            [self.keyDelegate performSelector:@selector(toggleMute)];
        }
        return;
    }

    [super keyDown:event];
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
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    cpuMonitor = new CPUUsageMonitor();
    self.isMuted = NO;

    // Speech setup
    self.speech = [[NSSpeechSynthesizer alloc] init];
    self.speech.voice = @"com.apple.speech.synthesis.voice.Alex";
    [self.speech setRate:170.0];
    self.speech.volume = 1.0;

    [self.speech startSpeakingString:
     @"Hello it's very nice to meet you. If you struggle with your vision, you can press the button on the left to open the website. it's the white text under the black box that includes the cpu usage graph. If you want to hear my voice again, you can press the button on the right. it's the white text under the black box that includes the cpu usage graph."];


    // Music setup
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"musicvro" ofType:@"mp3"];

    if (musicPath) {

        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        NSError *error = nil;

        self.backgroundMusicPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];

        if (!error) {

            self.backgroundMusicPlayer.numberOfLoops = -1;
            self.backgroundMusicPlayer.volume = 0;

            [self.backgroundMusicPlayer prepareToPlay];
            [self.backgroundMusicPlayer play];
        }
    }


    // Window
    NSRect frame = NSMakeRect(0, 0, 900, 760);

    self.window = [[KeyWindow alloc] initWithContentRect:frame
                                               styleMask:(NSWindowStyleMaskTitled |
                                                          NSWindowStyleMaskClosable |
                                                          NSWindowStyleMaskResizable)
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];

    ((KeyWindow *)self.window).keyDelegate = self;

    [self.window setTitle:@"CPU Monitor"];
    [self.window setDelegate:self];


    // Label title
    NSTextField *labelText =
    [[NSTextField alloc] initWithFrame:NSMakeRect(80, 620, 740, 80)];

    [labelText setStringValue:@"CPU Usage:"];
    [labelText setBezeled:NO];
    [labelText setDrawsBackground:NO];
    [labelText setEditable:NO];
    [labelText setFont:dyslexicFont(72)];

    [[self.window contentView] addSubview:labelText];


    // CPU value label
    self.cpuLabel =
    [[NSTextField alloc] initWithFrame:NSMakeRect(80, 520, 740, 110)];

    [self.cpuLabel setEditable:NO];
    [self.cpuLabel setBezeled:NO];
    [self.cpuLabel setDrawsBackground:NO];
    [self.cpuLabel setFont:dyslexicFont(96)];
    [self.cpuLabel setStringValue:@"0.00%"];

    [[self.window contentView] addSubview:self.cpuLabel];


    // Graph
    self.graphView =
    [[CPUGraphView alloc] initWithFrame:NSMakeRect(60, 120, 780, 360)];

    [[self.window contentView] addSubview:self.graphView];


    // Website button
    self.websiteButton =
    [[NSButton alloc] initWithFrame:NSMakeRect(20, 30, 420, 110)];

    [self.websiteButton setTitle:@"Website"];
    [self.websiteButton setFont:dyslexicFont(54)];
    [self.websiteButton setTarget:self];
    [self.websiteButton setAction:@selector(openWebsite)];

    [[self.window contentView] addSubview:self.websiteButton];


    // Mute button
    self.muteButton =
    [[NSButton alloc] initWithFrame:NSMakeRect(460, 30, 420, 110)];

    [self.muteButton setTitle:@"Mute/replay"];
    [self.muteButton setFont:dyslexicFont(54)];
    [self.muteButton setTarget:self];
    [self.muteButton setAction:@selector(toggleMute)];

    [[self.window contentView] addSubview:self.muteButton];


    // Footer contact label
    NSTextField *footerLabel =
    [[NSTextField alloc] initWithFrame:NSMakeRect(20, 5, 860, 45)];

    [footerLabel setStringValue:@"Contact us: 1-800-123-4567. No data is saved; all data is deleted after the program stops. Privacy laws like GDPR/CCPA don't apply to this program."];
    [footerLabel setBezeled:NO];
    [footerLabel setDrawsBackground:NO];
    [footerLabel setEditable:NO];
    [footerLabel setFont:dyslexicFont(14)];
    [footerLabel setTextColor:[NSColor grayColor]];
    [footerLabel setAlignment:NSTextAlignmentCenter];
    [footerLabel setLineBreakMode:NSLineBreakByWordWrapping];

    [[self.window contentView] addSubview:footerLabel];


    [self.window makeKeyAndOrderFront:nil];


    // CPU refresh timer
    updateTimer =
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(refreshCPU)
                                   userInfo:nil
                                    repeats:YES];
}


- (void)refreshCPU {

    if (!cpuMonitor) return;

    double usage = cpuMonitor->sample();

    [self.cpuLabel setStringValue:
     [NSString stringWithFormat:@"%.2f%%", usage]];

    [self.graphView addPoint:usage];
}


- (void)openWebsite {

    NSURL *url = [NSURL URLWithString:@"http://localhost:8080"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (void)toggleMute {

    self.isMuted = !self.isMuted;

    if (self.isMuted) {

        [self.speech stopSpeaking];
        [self.backgroundMusicPlayer pause];

        [self.muteButton setTitle:@"Unmute"];

    } else {

        [self.muteButton setTitle:@"Mute"];

        self.speech.volume = 1.0;

        [self.speech startSpeakingString:
         @"Yo what is up guys, if you lowkey got eyes that work enough that you can see the screen, you can see press the website button to submit your cpu percentage for everyone to see. if you don't have eyes that work, you can also press the spacebar to open the website, and if you want to hear my voice again, please press the M key to unmute me. Enjoy!"];

        [self.backgroundMusicPlayer play];
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