//
//  RecordingsTableViewController.h
//  PlayRecordings
//
//  Created by Bhat, Rohit on 11/19/14.
//  Copyright (c) 2014 Bhat, Rohit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordingsTableVCDelegate <NSObject>
- (void)sendSelectedItem:(NSString *)selectedItem;
@end

@interface RecordingsTableViewController : UITableViewController

@property (nonatomic, weak) id <RecordingsTableVCDelegate> delegateRecordingsTableVC;

@end





