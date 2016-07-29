//
//  StartupViewController.h
//  SageRoadShowYoutube
//
//  Created by Bhat, Rohit on 10/30/14.
//  Copyright (c) 2014 Bhat, Rohit. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MediaPlayerViewController.h"
#import "RecordingsTableViewController.h"

@interface StartupViewController : UIViewController <RecordingsTableVCDelegate>
@property (nonatomic, strong) MediaPlayerViewController *viewControllerMediaPlayer;
@property (nonatomic, strong) RecordingsTableViewController *tableViewControllerRecordings;
@end
