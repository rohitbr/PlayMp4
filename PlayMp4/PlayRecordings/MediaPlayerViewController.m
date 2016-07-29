//
//  MediaPlayerViewController.m
//  PlayRecordings
//
//  Created by Bhat, Rohit on 11/18/14.
//  Copyright (c) 2014 Bhat, Rohit. All rights reserved.
//

#import "MediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#define IPAD10_1_WIDTH_IN_LANDSCAPE  1024
#define IPAD10_1_HEIGHT_IN_LANDSCAPE 748
#define PROGBAR_WIDTH(x) (IPAD10_1_PROGBAR_WIDTH * x)/IPAD10_1_WIDTH_IN_LANDSCAPE
#define PROGBAR_HEIGHT(x) (IPAD10_1_PROGBAR_HEIGHT * x)/IPAD10_1_HEIGHT_IN_LANDSCAPE
#define PROGBAR_UI_ELEMENTS_HEIGHT(x) (IPAD10_1_PROGRESS_UI_ELEMENTS_HEIGHT * x)/IPAD10_1_HEIGHT_IN_LANDSCAPE
#define PROGBAR_TIME_LABEL_WIDTH(x) (IPAD10_1_PROGBAR_TIME_LABEL_WIDTH * x)/IPAD10_1_WIDTH_IN_LANDSCAPE

#define IPAD10_1_X_OFFSET 20
#define X_OFFSET(x) (IPAD10_1_X_OFFSET * x) / IPAD10_1_WIDTH_IN_LANDSCAPE

#define SPACING_TIMELABEL_AND_SLIDER(x) (IPAD10_1_SPACING_TIMELABEL_AND_SLIDER * x) / IPAD10_1_WIDTH_IN_LANDSCAPE


static NSString * kLabelFontName = @"HelveticaNeue";
static const CGFloat kAlphaUserInterfaceProgressBarShown = 0.8;
static const CGFloat kAlphaUserInterfaceHidden = 0.0;
static const CGFloat kAnimationDuration = 0.3;
static const CGFloat kAlphaUserInterfaceControlbarShown = 0.8;
NSString * const kNotificationHideMediaPlayerControls  = @"MediaPlayerHideControlsNotification";


// Player Progressbar
#define IPAD10_1_PROGBAR_WIDTH  1024
#define IPAD10_1_PROGBAR_HEIGHT 50
#define IPAD10_1_SPACING_TIMELABEL_AND_SLIDER 4
#define IPAD10_1_PROGRESS_UI_ELEMENTS_HEIGHT 60
#define IPAD10_1_PROGBAR_TIME_LABEL_WIDTH 60

@interface MediaPlayerViewController ()

@property (strong,nonatomic) MPMoviePlayerController *controllerMoviePlayer;
@property (retain, nonatomic) IBOutlet UISlider *sliderProgress;
@property (retain, nonatomic) IBOutlet UIView *controlsView;
@property (assign, nonatomic) NSUInteger controlsViewWidth;
@property (assign, nonatomic) NSUInteger controlsViewHeight;
@property (assign, nonatomic) NSInteger statusBarHeight;
@property (assign, nonatomic) NSUInteger toolBarHeight;
@property (retain, nonatomic) IBOutlet UIView *viewPlayerProgressBar;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeWatched;
@property (retain, nonatomic) IBOutlet UILabel *labelTimeRemaining;
@property (retain, nonatomic) NSTimer *timerPlaybackTracker;
@property (retain, nonatomic) NSDictionary *videoInformationDictionary;
@property (assign, nonatomic) BOOL playbackTimeSynchronized;
@property (assign, nonatomic) MPMoviePlaybackState playbackstatePreSeeking;
@property (assign, nonatomic)BOOL userInterfaceTimerEnabled;
@property (retain, nonatomic) NSTimer *timerHideUserInterface;
@property (assign, nonatomic) BOOL isUserInterfaceHidden;

@end

@implementation MediaPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.statusBarHeight = [[UIApplication sharedApplication]statusBarFrame].size.width;
    self.toolBarHeight = 44;
    [self setUserInterfaceTimerEnabled:YES];
    [self addObservers];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSURL *url = nil;
    
    url = [NSURL URLWithString:@"something.mp4"];
    
    [self setPlayerViewWithUrl:url];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self initialize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieplayerPlaybackDidFinishNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[self controllerMoviePlayer]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieplayerPlaybackIsPreparedToPlayNotification:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:[self controllerMoviePlayer]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setDurationNotification:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:[self controllerMoviePlayer]];
}

#pragma Observer Selectors

- (void)movieplayerPlaybackDidFinishNotification:(NSNotification *)notification
{
    NSDictionary *reasonDictionary = [notification userInfo];
    MPMovieFinishReason reasonFinish = [[reasonDictionary objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    
    switch (reasonFinish)
    {
        case MPMovieFinishReasonPlaybackEnded:
            
            NSLog(@"MPMovieFinishReasonPlaybackEnded");
            
            break;
            
        case MPMovieFinishReasonUserExited:
            
            NSLog(@"MPMovieFinishReasonUserExited");
            
            break;
            
        case MPMovieFinishReasonPlaybackError:
            
            NSLog(@"MPMovieFinishReasonPlaybackError");
            
            break;
            
        default:
            
            //NSAssert(NO, @"WHY ARE WE HERE?");
            break;
    }
    
    for (UIView *subView in self.view.subviews)
    {
        [subView removeFromSuperview];
    }
}

- (void)movieplayerPlaybackIsPreparedToPlayNotification:(NSNotification *)notification
{
    [[self controllerMoviePlayer] play];
    [self startHideUserInterfaceTimer];
}

- (void)setDurationNotification:(NSNotification *)notification
{
    if ([[self controllerMoviePlayer] currentPlaybackTime] > [[self controllerMoviePlayer] duration])
    {
        [[self controllerMoviePlayer] setCurrentPlaybackTime:[[self controllerMoviePlayer] duration]];
    }
    
    [[self sliderProgress] setMaximumValue:[[self controllerMoviePlayer] duration]];
    
    [self updateTimeDisplayElapsedTime:[[self controllerMoviePlayer] currentPlaybackTime]
                             totalTime:[[self controllerMoviePlayer] duration]];
}


#pragma Private Functions

- (void) initialize
{
    // Add a controls view in front of the player view, so the player view can be scalled
    UIView *controlsView = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [self setControlsView:controlsView];
    [[self controlsView] setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:[self controlsView]];
    [self setControlsViewWidth:[self controlsView].frame.size.width];
    [self setControlsViewHeight:[self controlsView].frame.size.height];
    
    [self startPlaybackTrackerTimer];
    [self loadPlayerProgressBar];
}

- (void)startPlaybackTrackerTimer
{
    if (![[self timerPlaybackTracker] isValid])
    {
        [self setTimerPlaybackTracker:[NSTimer scheduledTimerWithTimeInterval:1.0
                                                                       target:self
                                                                     selector:@selector(notificationPlaybackTrackerTimer:)
                                                                     userInfo:nil
                                                                      repeats:YES]];
    }
}

- (void)notificationPlaybackTrackerTimer:(NSTimer *)timer
{
    if (MPMoviePlaybackStatePlaying == [[self controllerMoviePlayer] playbackState])
    {
        [self updateTimeDisplayElapsedTime:[[self controllerMoviePlayer] currentPlaybackTime]
                                 totalTime:[[self controllerMoviePlayer] duration]];
    }
    
    [self updateNowPlayingInfo];
}


- (void)updateTimeDisplayElapsedTime:(NSTimeInterval)elapsedTime totalTime:(NSTimeInterval)totalTime
{
    if (isnan(elapsedTime) || (0.0 > elapsedTime))
    {
        elapsedTime = 0;
    }
    
    if (isnan(totalTime))
    {
        totalTime = 0;
    }
    
    if (elapsedTime >= totalTime)
    {
        elapsedTime = totalTime;
    }
    
    [[self labelTimeWatched] setText:[self stringForTime:elapsedTime]];
    
    [[self sliderProgress] setValue:elapsedTime];
    
    [[self labelTimeRemaining] setText:[self stringForTime:(totalTime - elapsedTime)]];
}

- (NSString *)stringForTime:(NSTimeInterval)time
{
    const NSInteger kSecondsInAnHour = 3600;
    const NSInteger kSecondsInAMinute = 60;
    
    NSString *returnVal;
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    if (kSecondsInAnHour <= time)
    {
        // we have hours because we have more than kSecondsInAnHour seconds in our time
        hours = time / kSecondsInAnHour;
        
        time -= (hours * kSecondsInAnHour);
    }
    
    if (kSecondsInAMinute <= time)
    {
        // we have minutes because we have more than kSecondsInAMinute seconds remaining
        minutes = time / kSecondsInAMinute;
        seconds = time - (minutes * kSecondsInAMinute);
    }
    else
    {
        seconds = time;
    }
    
    if (0 < hours)
    {
        returnVal = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        returnVal = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
    return returnVal;
}


- (void)updateNowPlayingInfo
{
    float lastSetRate = [[[self videoInformationDictionary] objectForKey:MPNowPlayingInfoPropertyPlaybackRate] floatValue];
    
    // update if
    // 1. the playback time needs to be synchronized
    // 2. the playback rate has changed since we last set it
    BOOL doUpdate = ![self playbackTimeSynchronized] || ([[self controllerMoviePlayer] currentPlaybackRate] != lastSetRate);
    
    if (doUpdate)
    {
        // This needs to be done to keep the progress bar on remote audio sinks such as the AppleTV accurate.
        // It should not be done "too often"
        // Apple suggests, "Update the elapsed time and playback rate whenever the playback rate changes."
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self videoInformationDictionary]];
        
        float currentPlaybackRate = [[self controllerMoviePlayer] currentPlaybackRate];
        NSTimeInterval currentPlaybackTime = [[self controllerMoviePlayer] currentPlaybackTime];
        
        // currentPlaybackTime is set to a value which is NaN (Not a Number) when this first starts
        if (!isnan(currentPlaybackTime))
        {
            // NSLog(@"\n\n\nupdating playback rate: %.1f and playback time: %.1f\n\n\n", currentPlaybackRate, currentPlaybackTime);
            [dictionary setObject:[NSNumber numberWithDouble:currentPlaybackRate]
                           forKey:MPNowPlayingInfoPropertyPlaybackRate];
            
            [dictionary setObject:[NSNumber numberWithDouble:currentPlaybackTime]
                           forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            
            [self setVideoInformationDictionary:dictionary];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[self videoInformationDictionary]];
            
            [self setPlaybackTimeSynchronized:YES];
        }
    }
}

- (void) loadPlayerProgressBar
{
    CGFloat kViewProgbarWidth = PROGBAR_WIDTH(self.controlsViewWidth);
    CGFloat kViewProgbarHeight = PROGBAR_HEIGHT(self.controlsViewHeight);
    CGFloat kProgressElementsHeight = PROGBAR_UI_ELEMENTS_HEIGHT(self.controlsViewHeight);
    CGFloat kProgbarTimeLabelWidth = PROGBAR_TIME_LABEL_WIDTH(self.controlsViewWidth);
    
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    UISlider *slider;
    UILabel *label;
    NSInteger fontSize = 16;
    NSInteger padding = 20;
    
    // Main view for Progressbar
    x = 0;
    w = kViewProgbarWidth;
    h = kViewProgbarHeight;
    y = self.view.frame.size.height - h - padding;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.8];
    [view setAlpha:kAlphaUserInterfaceProgressBarShown];
    [self setViewPlayerProgressBar:view];
    
    // Time Watched
    x = X_OFFSET(self.controlsViewWidth);
    h = kProgressElementsHeight;
    y = ([self viewPlayerProgressBar].frame.size.height - h) /2;
    w = kProgbarTimeLabelWidth;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:kLabelFontName
                                   size:fontSize]];
    [label setNumberOfLines:1];
    [label setText:[self stringForTime:0]];
    [self setLabelTimeWatched:label];
    
    
    // Progress Slider
    w = self.controlsViewWidth
    - 2 * kProgbarTimeLabelWidth
    - 2 * X_OFFSET(self.controlsViewWidth)
    - 2 * SPACING_TIMELABEL_AND_SLIDER(self.controlsViewWidth);
    h = kProgressElementsHeight;
    x = X_OFFSET(self.controlsViewWidth)
    + SPACING_TIMELABEL_AND_SLIDER(self.controlsViewWidth)
    + kProgbarTimeLabelWidth;
    y = ([self viewPlayerProgressBar].frame.size.height - h) /2;
    
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [slider setMinimumValue:0.0];
    [slider setMaximumValue:[[self controllerMoviePlayer] duration]];
    [slider setContinuous:YES];
    [slider setBackgroundColor:[UIColor blackColor]];
    
    [slider addTarget:self
               action:@selector(sliderProgressStartChange:)
     forControlEvents:(UIControlEventTouchDragInside | UIControlEventTouchDragOutside)];
    
    [slider addTarget:self
               action:@selector(sliderProgressEndChange:)
     forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    
    [self setSliderProgress:slider];
    
    
    // Time Remaining
    w = kProgbarTimeLabelWidth;
    x = X_OFFSET(self.controlsViewWidth)
    + self.sliderProgress.frame.size.width
    + kProgbarTimeLabelWidth
    + (2 * SPACING_TIMELABEL_AND_SLIDER(self.controlsViewWidth));
    h = kViewProgbarHeight;
    y = ([self viewPlayerProgressBar].frame.size.height - h) /2;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:kLabelFontName
                                   size:fontSize]];
    [label setNumberOfLines:1];
    [label setText:[self stringForTime:0]];
    
    [self setLabelTimeRemaining:label];
    
    // Add these controls to Main Progress View
    [[self viewPlayerProgressBar] addSubview:[self labelTimeWatched]];
    [[self viewPlayerProgressBar] addSubview:[self sliderProgress]];
    [[self viewPlayerProgressBar] addSubview:[self labelTimeRemaining]];
    
    // Add the Main Progress View to the movie player
    [[self controlsView] addSubview:[self viewPlayerProgressBar]];
}


#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isUserInterfaceHidden])
    {
        [self showUserInterface];
        
        // we only auto-hide the user interface it the video is currently playing
        if (MPMoviePlaybackStatePlaying == [[self controllerMoviePlayer] playbackState])
        {
            [self startHideUserInterfaceTimer];
        }
    }
}

#pragma mark - IBACTION (ProgressInfoBar)

// Slider Pressed

- (IBAction)sliderProgressStartChange:(UISlider *)sender
{
    // we don't need the timer conflicting with our slide motion
    [self stopPlaybackTrackerTimer];
    
    // the first time here we are in a state other than seeking (forward/back) so save the current
    // state so that we can set it again once we are done seeking
    if ((MPMoviePlaybackStatePlaying == [[self controllerMoviePlayer] playbackState]) ||
        (MPMoviePlaybackStatePaused == [[self controllerMoviePlayer] playbackState]))
    {
        [self setPlaybackstatePreSeeking:[[self controllerMoviePlayer] playbackState]];
    }
    
    // the user is moving the slider, stop the timer so that the ui stays visible
    [self stopHideUserInterfaceTimer];
    
    // set the playback time to the corresponding slider position
    [[self controllerMoviePlayer] setCurrentPlaybackTime:[sender value]];
    
    [self updateTimeDisplayElapsedTime:[sender value]
                             totalTime:[sender maximumValue]];
    
}


- (void)stopPlaybackTrackerTimer
{
    if ([[self timerPlaybackTracker] isValid])
    {
        [[self timerPlaybackTracker] invalidate];
    }
}


- (IBAction)sliderProgressEndChange:(UISlider *)sender
{
    // set the playback time to the corresponding slider position
    [[self controllerMoviePlayer] setCurrentPlaybackTime:[[self sliderProgress] value]];
    
    if (MPMoviePlaybackStatePaused == [self playbackstatePreSeeking])
    {
        [[self controllerMoviePlayer] pause];
    }
    else if (MPMoviePlaybackStatePlaying == [self playbackstatePreSeeking])
    {
        [[self controllerMoviePlayer] play];
        
        // if we were currently playing we want to hide the user interface
        [self startHideUserInterfaceTimer];
    }
    
    [self startPlaybackTrackerTimer];
    [self setPlaybackTimeSynchronized:NO];
}


- (void)showUserInterface
{
    [self updateTimeDisplayElapsedTime:[[self controllerMoviePlayer] currentPlaybackTime]
                             totalTime:[[self controllerMoviePlayer] duration]];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self viewPlayerProgressBar] setAlpha:kAlphaUserInterfaceControlbarShown];
                     } completion:nil];
    
    // UI is considered visible even before animation is completed
    [self setIsUserInterfaceHidden:NO];
}

- (void)stopHideUserInterfaceTimer
{
    if ( [self userInterfaceTimerEnabled] && [[self timerHideUserInterface] isValid])
    {
        [[self timerHideUserInterface] invalidate];
        [self setTimerHideUserInterface:nil];
    }
}

- (void)startHideUserInterfaceTimer
{
    if([self userInterfaceTimerEnabled])
    {
        [self setTimerHideUserInterface:[NSTimer scheduledTimerWithTimeInterval:5.0
                                                                         target:self
                                                                       selector:@selector(notificationHideUserInterfaceTimer:)
                                                                       userInfo:nil
                                                                        repeats:NO]];
    }
}

- (void)hideUserInterface
{
    // animate and set hidden only if animation completes (UI really is hidden)
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self viewPlayerProgressBar] setAlpha:kAlphaUserInterfaceHidden];
                     } completion:^(BOOL finished) {
                         if (finished)
                         {
                             [self setIsUserInterfaceHidden:YES];
                         }
                     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideMediaPlayerControls
                                                        object:self
                                                      userInfo:nil];
}

- (void)notificationHideUserInterfaceTimer:(NSTimer *)timer
{
    if ([[self timerHideUserInterface] isValid])
    {
        [self hideUserInterface];
    }
}

- (void) restartPlayBack:(NSString *)recordingLocation
{
    NSURL *url = nil;
    
    NSString *filePathStr = [[NSBundle mainBundle] pathForResource:recordingLocation ofType:@"mp4"];
    
    url = [NSURL fileURLWithPath:filePathStr];
    
    for (UIView *subView in self.view.subviews)
    {
        [subView removeFromSuperview];
    }
    
    self.controllerMoviePlayer = nil;

    [self stopPlaybackTrackerTimer];
    
    [self setPlayerViewWithUrl:url];
    [self initialize];
}

- (void) setPlayerViewWithUrl: (NSURL*) url
{
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [player setContentURL:url];
    [player setMovieSourceType:MPMovieSourceTypeFile];
    [[player view] setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    player.scalingMode = MPMovieScalingModeNone;
    player.controlStyle = MPMovieControlStyleNone;
    player.backgroundView.backgroundColor = [UIColor blackColor];
    player.repeatMode = MPMovieRepeatModeNone;
    
    self.controllerMoviePlayer = player;
    
    [[self controllerMoviePlayer] prepareToPlay];
    
    [self setView:self.controllerMoviePlayer.view];

    if (player)
    {
        [self.controllerMoviePlayer play];
    }
}


@end
