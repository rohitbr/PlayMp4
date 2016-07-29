//
//  StartupViewController.m
//
//  Created by Rohit Bhat on 11/04/14.
//

#import "StartupViewController.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>

#define IPAD10_1_WIDTH_IN_LANDSCAPE  1024
#define IPAD10_1_HEIGHT_IN_LANDSCAPE 768
const NSInteger kButtonDimension = 60;
const NSInteger kXOffset = 80;
const NSInteger kYOffset = 70;
NSString * const kImageMinimize = @"minimize.png";
NSString * const kImageExpand = @"expand.png";

@interface StartupViewController() <MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) BOOL videoIsExpanded;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlayBack;

@end

@implementation StartupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                           bundle:[NSBundle mainBundle]];
    
    self.viewControllerMediaPlayer = [myStoryboard instantiateViewControllerWithIdentifier:@"storyBoardIdentifierMediaPlayer"];
    [self.view addSubview:self.viewControllerMediaPlayer.view];
    [self addChildViewController:self.viewControllerMediaPlayer];
    [self.viewControllerMediaPlayer didMoveToParentViewController:self];
    
    self.tableViewControllerRecordings = [myStoryboard instantiateViewControllerWithIdentifier:@"storyBoardIdentifierRecordingTableView"];
    [self.view addSubview:self.tableViewControllerRecordings.view];
    [self addChildViewController:self.tableViewControllerRecordings];
    self.tableViewControllerRecordings.delegateRecordingsTableVC = self;
    [self.tableViewControllerRecordings didMoveToParentViewController:self];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    NSInteger deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    if((deviceOrientation == UIInterfaceOrientationLandscapeLeft) || (deviceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        x = 0;
        y = 0;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.viewControllerMediaPlayer.view setFrame:CGRectMake(x, y, w, h)];
        
        x = 0;
        y = viewHeight/2;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.tableViewControllerRecordings.view setFrame:CGRectMake(x, y, w, h)];
    }
    else if(deviceOrientation == UIInterfaceOrientationPortrait || (deviceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        x = 0;
        y = 0;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.viewControllerMediaPlayer.view setFrame:CGRectMake(x, y, w, h)];
        
        x = 0;
        y = viewHeight/2;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.tableViewControllerRecordings.view setFrame:CGRectMake(x, y, w, h)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.hud.isHidden)
    {
        [self.hud hide:YES];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - YUVDisplayGLViewControllerDelegate implementation


- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
    
	[self.hud removeFromSuperview];
}

#pragma mark - private instance methods

- (void)displayHUDWithMessage:(NSString *)message
{
	self.hud = [MBProgressHUD showHUDAddedTo:self.view
                                    animated:YES];
    
    self.hud.labelText = message;
    
    // register for HUD callbacks so we can remove it from the window at the right time
    
	self.hud.delegate = self;
}

#pragma mark - RecordingsTableVCDelegate implementstion

- (void)sendSelectedItem:(NSString *)selectedItem;
{
    [[self viewControllerMediaPlayer] restartPlayBack:selectedItem];
}

- (void)orientationChanged:(NSNotification *)notification
{
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        x = 0;
        y = 0;
        w = viewHeight;
        h = viewWidth/2;
        
        [self.viewControllerMediaPlayer.view setFrame:CGRectMake(x, y, w, h)];
        
        x = 0;
        y = viewWidth/2;
        w = viewHeight;
        h = viewWidth/2;
        
        [self.tableViewControllerRecordings.view setFrame:CGRectMake(x, y, w, h)];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        x = 0;
        y = 0;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.viewControllerMediaPlayer.view setFrame:CGRectMake(x, y, w, h)];
    
        x = 0;
        y = viewHeight/2;
        w = viewWidth;
        h = viewHeight/2;
        
        [self.tableViewControllerRecordings.view setFrame:CGRectMake(x, y, w, h)];
    }
}

@end
