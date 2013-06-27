//
//  RootViewController.m
//  CodeDataSample01
//
//  Created by sumantar on 24/06/13.
//  Copyright (c) 2013 sumantar. All rights reserved.
//

#import "RootViewController.h"
#import "Event.h"

@interface RootViewController ()

@end

@implementation RootViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set the title.
    self.title = @"Locations";
    // Set up the buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    _addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                 target:self action:@selector(addEvent)];
    _addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _addButton;
    
    //initalize array
    _eventsArray = [[NSMutableArray alloc] init];
    
    // Start the location manager.
    [[self locationManager] startUpdatingLocation];
    
    /*
     //\\********* No Predicate is used. *******************\\
     
    //Read from the coredata table and populate it.
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    //Set sort descriptor. Sorting as per the date.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    //Now fetch records from CoreData
    NSError *error = nil;
    NSMutableArray *fetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if(fetchResults == nil)
    {
        NSLog(@"Error while retrieving Data");
    }
    
    [self setEventsArray:fetchResults];
     
     */
    
//    NSString *attributeName = @"firstName";
//    NSString *attributeValue = @"Adam";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ like %@",
//                              attributeName, attributeValue];
    
     //\\*********  Predicate is used. *******************\\
     
     //Read from the coredata table and populate it.
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
     [request setEntity:entity];
    
    //We can create predicate in 3ways
    //1. Using fromatted string
    //2. Directly in code
    //3. Using Predicate Template
    
    /*
    //#########################################
    //1. Using fromatted string
    
     NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > %d", 37];
     //NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > %@", [NSNumber numberWithInt:37]];
    //Simillarly we will substitute for Bool: [NSNumber numberWithBool:aBool]
    */
    
    //#########################################
    //2. Directly in code. You need to create NSExpression etc..
    //We can skip this approch
    
    //#########################################
    //3. Using Predicate Template
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > $LATITUDE_VALUE"];
    //Here, we need to provide substitution value for $LATITUDE_VALUE
    //Internally, it will create NSExpression etc...
    
    
    
    
     [request setPredicate:filter];
    
     //Set sort descriptor. Sorting as per the date.
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
     
     [request setSortDescriptors:sortDescriptors];
    
    //The following we can set the substitution value for prdicate.
    
    //1. Save this fetch request in ManagedObjectModel object
     NSManagedObjectModel *model = [[_managedObjectContext persistentStoreCoordinator] managedObjectModel];
     [model setFetchRequestTemplate:request forName:@"AnyName"];
    
     //2. Moify this request by providing the substitute values.
        //Rather you are reading this template through ManagedObjectModel and provide substitute values
        //The same API "fetchRequestFromTemplateWithName" is used when we create predicate using XCode CoreData Tool
    
     request =  [model fetchRequestFromTemplateWithName:@"AnyName"
                                 substitutionVariables:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:37] forKey:@"LATITUDE_VALUE"]];
     
     //Now fetch records from CoreData
     NSError *error = nil;
     NSMutableArray *fetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
     
     if(fetchResults == nil)
     {
     NSLog(@"Error while retrieving Data");
     }
     
     [self setEventsArray:fetchResults];
     
     
    
    /*
     //\\********* Usig XCode Predicate Builder *******************\\
    NSManagedObjectModel *model = [[_managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *reqTemplate = [[model fetchRequestTemplateForName:@"FetchReq"] copy];
    
    //Set sort descriptor. Sorting as per the date.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [reqTemplate setSortDescriptors:sortDescriptors];
    
    //Now fetch records from CoreData
    NSError *error = nil;
    NSMutableArray *fetchResults = [[_managedObjectContext executeFetchRequest:reqTemplate error:&error] mutableCopy];
    
    if(fetchResults == nil)
    {
        NSLog(@"Error while retrieving Data");
    }
    
    
    
    [self setEventsArray:fetchResults];
     */
}

- (void) addEvent
{
    CLLocation *location = [_locationManager location];
    if (location) {
        //CLLocationCoordinate2D coordinate = [location coordinate];
        Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        
        CLLocationCoordinate2D coordinate = [location coordinate];
        [event setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
        [event setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
        [event setCreationDate:[NSDate date]];
        
        //Now Save the object to persistent store
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"Could not save: %@", [error description]);
        }
        
        [_eventsArray insertObject:event atIndex:0];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


- (CLLocationManager *)locationManager
{
    if (_locationManager != nil) {
        return _locationManager;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.delegate = self;
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    _addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    _addButton.enabled = NO;
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
    return [_eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rootViewPrototypeCell";  //@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // A date formatter for the time stamp.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    // A number formatter for the latitude and longitude.
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:3];
    }
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:100];
    Event *event = (Event *)[_eventsArray objectAtIndex:indexPath.row];
    label1.text = [dateFormatter stringFromDate:[event creationDate]];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:200];
    NSString *string = [NSString stringWithFormat:@"%@, %@",
                        [numberFormatter stringFromNumber:[event latitude]],
                        [numberFormatter stringFromNumber:[event longitude]]];
    label2.text = string;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Get the managed object from the array
        NSManagedObject *eventsToDelete = [_eventsArray objectAtIndex:indexPath.row];
        [_managedObjectContext deleteObject:eventsToDelete];
        
        //Remove from the array
        [_eventsArray removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //Commit the changes to persistence store
        NSError *error;
        if(![_managedObjectContext save:&error])
        {
            NSLog(@"Error while saving the records");
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
