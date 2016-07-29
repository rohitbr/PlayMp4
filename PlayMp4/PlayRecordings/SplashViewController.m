//
//  SplashViewController.m
//  TransfersEngineTabbed
//
//  Created by Bhat, Rohit on 10/30/14.
//  Copyright (c) 2014 Echostar. All rights reserved.
//

#import "SplashViewController.h"
#import "MBProgressHUD.h"
#import "StartupViewController.h"

@interface SplashViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SplashViewController


#pragma mark - ViewCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayHUDWithMessage:@"Initializing"];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(selectorStartupTimer)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.hud.isHidden)
    {
        [self.hud hide:YES];
    }
    
    [super viewWillDisappear:animated];
}

- (void) viewDidUnload
{    
    [super viewDidUnload];
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - MBProgressHUDDelegate implementstion

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

- (void)selectorStartupTimer
{
    [self.timer invalidate];
    
    [self.hud hide:YES];
    
    [self continueToStartupView];
}

- (void)continueToStartupView
{
    [self performSegueWithIdentifier:@"segueModalRootView"
                              sender:self];
}

@end
