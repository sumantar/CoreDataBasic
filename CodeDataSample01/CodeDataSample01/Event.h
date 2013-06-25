//
//  Event.h
//  CodeDataSample01
//
//  Created by sumantar on 25/06/13.
//  Copyright (c) 2013 sumantar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
