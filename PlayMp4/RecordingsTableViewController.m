//
//  RecordingsTableViewController.m
//  PlayRecordings
//
//  Created by Bhat, Rohit on 11/19/14.
//  Copyright (c) 2014 Bhat, Rohit. All rights reserved.
//

#import "RecordingsTableViewController.h"
#import "CameraViewCell.h"

@interface RecordingsTableViewController ()

@property (nonatomic, strong) NSArray *cameraImages;
@property (nonatomic, strong) NSArray *cameraNames;
@property (nonatomic, strong) NSArray *arrayCameraRecordingName;

@end

@implementation RecordingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cameraImages = [@[@"CameraImage1.jpg",
                           @"CameraImage2.jpg",
                           @"CameraImage3.jpg",
                           @"CameraImage4.jpg",
                           @"CameraImage5.jpg",
                           @"CameraImage1.jpg",
                           @"CameraImage2.jpg",
                           @"CameraImage3.jpg",
                           @"CameraImage4.jpg",
                           @"CameraImage5.jpg",
                           @"CameraImage1.jpg",
                           @"CameraImage2.jpg",
                           @"CameraImage3.jpg",
                           @"CameraImage4.jpg"]
                         mutableCopy];
    
    self.cameraNames = [@[@"Camera1",
                          @"Camera2",
                          @"Camera3",
                          @"Camera4",
                          @"Camera5",
                          @"Camera6",
                          @"Camera7",
                          @"Camera8",
                          @"Camera9",
                          @"Camera10",
                          @"Camera11",
                          @"Camera12",
                          @"Camera13",
                          @"Camera14"]
                        mutableCopy];
    
    self.arrayCameraRecordingName = [@[
                             @"cam1",
                             @"cam2",
                             @"cam3",
                             @"cam4",
                             @"cam5",
                             @"cam6",
                             @"cam7",
                             @"cam8",
                             @"cam9",
                             @"cam10",
                             @"cam11",
                             @"cam12",
                             @"cam13",
                             @"cam14"]
                           mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.arrayCameraRecordingName.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CameraViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];

    cell.backgroundColor = [UIColor whiteColor];
    [cell.labelCamera setText:self.cameraNames[row]];
    UIImage *image =[UIImage imageNamed:self.cameraImages[row]];
    cell.imageViewCamera.image =image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    [self.delegateRecordingsTableVC sendSelectedItem:self.arrayCameraRecordingName[row]];
}

@end
