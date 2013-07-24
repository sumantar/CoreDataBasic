CoreDataBasic
=============
CoreData is simple to use.

As name suggest, this platform helps to store and retrieve objects in persistence store. i.e. storing and retrieving Data. Hence core data

1) CoreData stack
=>ManagedObjectContext (momc/momd compiler tools)
=>PersistenceStoreCoordiator -> ManagedObectModel
=>Persistence object Store
2) Managed Object: Each managed object to be registered with Managed Object Context. It is a wrapper of NSEntityDescription

It has three features:
=> Name
=> Class Name
=> Properties
  -> Attribute
	-> Relationship

Lets Discuss about details of the core data stack. Each Entity is described as NSEntityDescription. It is the schema of a table. However, each row of the table is described as NSManagedObject. It is a wrapper around NSEntityDescription. This object may contain NSAttributeDescription and NSRelationshipDescription.

We can create NSManagedObject automatically by selection the entity in designer view, file->new file->NSManagedObject. We should not create String property with copy attribute due to performance. It should be strong.

All the entries, attributes etc.. has associated with UserInfo dictionary.

There are mostly two methods used to create Managed Object of NSEntityDescription class
=> initWithEntity - This is used for reading, update or delete operation
=> insertNewObjectForEntity - This will be used to insert or add new data to the store.

NSManaged Object has universal identifier.
NSManagedObjectID *objID = [mo objectID];

We can check if it is temporaryID, [objID isTemporaryID], when object is dirty and not stored.

NSURL *url = [objID URIRepresentation];

3) Managed Object Model.
We can consider it as DB in RDBMS concept. It contains entities (tables), where we can add tables and remove table. Define Relationship (one-one, one-many, many-many).

In CoreData, architecture, we should always define reverse relationship. If one entity is related other one, then it is true for both.

We will create the managed object model using the following API:
=>initWithContentOfURL
=>mergedModelFromBundle

However, we can have the reference of managed object 
=>[[#ManagedObjectContext persistentStoreCoordinator] managedObjectModel];
=>[[ManagedObject entity] managedObjectModel];

4) Delete
We can use context to delete any object from DB.

We can delete and the following notification will be invoked.
=>NSManagedObjectContextObjectDidChangedNotification
=>NSManagedObjectContextDidSaveNotification

=====================================================================
#########################################################################
=====================================================================
1) I have created a sample project and selected coreData template. I have copied the following into my project in-order to support core data.
=>In App Delegate header file:

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

=>In the implementation file:
	==>>[Step-1]: Define Managed Object Model. Override the getter method as shown below. Here, we read bundle for file xcdatamodel and initialise it to create NSManagedObjectModel. As explained earlier, we will use, initWithContentOfURL:
	- (NSManagedObjectModel *)managedObjectModel
	{
    	if (_managedObjectModel != nil) {
        	return _managedObjectModel;
    	}
    	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CodeDataSample01" withExtension:@"momd"];
    	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    	return _managedObjectModel;
	}
	==>>[Step-2]: Define persistence store. Override the getter method as follows. We will define the database type/name. 

		---> Create NSPersistenceStoreCoordinator object from ManagedObjectModel as we created earlier.
		---> Define and attach store type and path of store
 
	- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
	{
    	if (_persistentStoreCoordinator != nil) {
        	return _persistentStoreCoordinator;
    	}
    
    	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CodeDataSample01.sqlite"];
    
    	NSError *error = nil;
    	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        	abort();
    	}
    
    	return _persistentStoreCoordinator;
	}
	==>>[Step-3]: Define Managed Object Context.
		---> Create NSManagedObjectContext using alloc/init
		---> Set the persistence store coordinator to the context.
	- (NSManagedObjectContext *)managedObjectContext
	{
    	if (_managedObjectContext != nil) {
        	return _managedObjectContext;
    	}
    
    	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    	if (coordinator != nil) {
        	_managedObjectContext = [[NSManagedObjectContext alloc] init];
        	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
    	}
    	return _managedObjectContext;
	}

	==>>[Step-4]: save Context
	- (void)saveContext
	{
    	NSError *error = nil;
    	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    	if (managedObjectContext != nil) {
        	if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            	abort();
        	}
    	}
	}

	==>>[Step-5]: Identify Document Directory.
	- (NSURL *)applicationDocumentsDirectory
	{
    	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	}

2) In Every Controller that wants to have access CoreData object, must have a reference to managed object context. We need to set it from app delegate.
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

3) Lets define our Model. Select .xcdatamodel file 
=> Add Entity (Similar to table in a DB). Then define each of the attributes and provide your validation of each such attributes.
=> Define the relationship. Must define the reverse relationship. It is essential for CodeData architecture.
=> Now generate the NSManagedObject class from the model. Select Model and then File->New File. Select NSManagedObject, generate. 
When we have multiple relationship, first object relationship will be of NSMagedObject type. Change it to the respective child ManagedObjectModel class.
=> Similarly we can add "Fetch Request". Here we will have graphical tool to identify our SQL Queries. We can also add "Add Configuration"

Note: We have the setup ready. We also have our model object ready. 

Now we can save this model object into database, edit this model object, Delete this model object as well.

CRUD Operation - Create, Read, Update and Delete Operation
================================================== 
1) Add object to data base. Lets we have a button on UI. When we tap, it will enter one record on DB. Lets add the following into the action of button event:
=> Create one NSManagedObject object using NSEntityDescription class method, insertNewObjectForEntity
=> Fill this model object with the appropriate data. Now the data is dirty.
=> Finally save it using context
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

2) Delete a record: 
=> Get NSManagedObject - either using a predicate or from internal reference from Array
=> Use deleteObject method of context to remove it.
=> Finally save it.
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

3) Use of predicate to fetch the data - NSFetchRequest. May be in viewDidLoad or any required method as follows
	--> No Predicate (SELECT * FROM MyEntity)
		=> Create one object of NSFetchRequest - alloc/init
		=> Get the Entity Using NSManagedObjectContext object
		=> Set this entity to the NSFetchRequestObject
		=> Next, Create NSSortDescriptor object - alloc/initWithKey
		=> Set this object to NSFetchRequest object
		=> Finally use context to execute this request
			==>> This will return an array of Managed Objects
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

	--> With Predicate
		=> We can create predicate in 3ways
    			==>> 1) Using formatted string
    			==>> 2) Directly in code
  			==>> 3) Using Predicate Template
	
		Using formatted string
		-----------------------------
		=> Create NSFetchRequest and set the Entity as explained earlier
		=> Create NSPredicate object and set it to the request
		=> Use fetchRequestWithPredicateName method
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
     	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
     	[request setEntity:entity];

		NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > %d", 37];
     	NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > %@", [NSNumber numberWithInt:37]];
     	{Simillarly we will substitute for Bool: [NSNumber numberWithBool:aBool]}

		[request setPredicate:filter];
    
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

		Directly in code
		---------------------
		=> We will not discuss as it takesNSExpression etc...

		Using Predicate Template
		----------------------------------
		NSPredicate *filter = [NSPredicate predicateWithFormat:@"latitude > $LATITUDE_VALUE"];
    
		{Here, we need to provide substitution value for $LATITUDE_VALUE
    	Internally, it will create NSExpression etc…}
        
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

		Using Xcode Predicate Builder
		-----------------------------------------
		=> It is easy and straight forward. Provide the predicate name in initialisation and then execute
    
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
		
		
Now We have setup the basic core data architecture. Suppose, you have dependance entities. We need not to fetch each individual entity rather fetch one entity and the dependant will automatically fetched.




