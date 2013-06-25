//
//  RootViewController.h
//  CodeDataSample01
//
//  Created by sumantar on 24/06/13.
//  Copyright (c) 2013 sumantar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController<CLLocationManagerDelegate>
@property(nonatomic, strong) NSMutableArray *eventsArray;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) UIBarButtonItem *addButton;
@end
