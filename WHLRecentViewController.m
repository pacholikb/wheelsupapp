//
//  WHLRecentViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLRecentViewController.h"
#import "REMenu.h"
#import "Trip.h"
#import "Flight.h"
#import "WHLNetworkManager.h"
#import "WHLSearchResultsViewController.h"
#import "SVProgressHUD.h"

@interface WHLRecentViewController ()

@end

@implementation WHLRecentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];
    
    [ self setTitle : @"Recent" ] ;
    
    WHLMenuViewController *nav = (WHLMenuViewController *)self.navigationController;
    [nav.menu setItems:@[ nav.searchItem, nav.profileItem, nav.discoveryItem]];
    
    self.navigationItem.leftBarButtonItem = [[ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"resultsSegue"])
    {
        WHLSearchResultsViewController *controller = (WHLSearchResultsViewController *)segue.destinationViewController;
        controller.flights = _flights;
        controller.trip = _selectedTrip;
    }
}

#pragma tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Trip *trip = (Trip *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
   
    UILabel *fromLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *toLabel = (UILabel *)[cell viewWithTag:2];
    
    NSDictionary *dictionary = [trip.trips firstObject];
    fromLabel.text = [NSString stringWithFormat:@"%@,\n%@",[dictionary valueForKey:@"departure_name"],[dictionary valueForKey:@"departure_country_name"]];
    toLabel.text = [NSString stringWithFormat:@"%@,\n%@",[dictionary valueForKey:@"arrival_name"],[dictionary valueForKey:@"arrival_country_name"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedTrip = (Trip *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [self findFlights];
}

- (void)findFlights
{
    NSDictionary *dictionary = [_selectedTrip.trips firstObject];
        __weak typeof (self) wself = self;
    
    [SVProgressHUD showWithStatus:@"Searching." maskType:SVProgressHUDMaskTypeBlack];
    [[WHLNetworkManager sharedInstance] makeSearchRequestFrom:[dictionary valueForKey:@"departure_code"] to:[dictionary valueForKey:@"arrival_code"] when:nil returnOn:nil adults:nil children: nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            if(mappingResult.array.count > 0) {
                Trip *tripFound = [mappingResult.array firstObject];
                
                [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:tripFound.searchId andTripId:[[tripFound.trips firstObject] valueForKey:@"id"] stops:nil maxrrice:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    
                    [SVProgressHUD dismiss];
                    
                    if(mappingResult.array.count > 0)
                    {
                        wself.flights = mappingResult.array;
                        [wself performSegueWithIdentifier:@"resultsSegue" sender:nil];
                    }
                    else
                        [wself showDialogWithTitle:@"Oops!" andMessage:@"No flights found!"];
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [SVProgressHUD dismiss];
                } numberOfTimes:8];
                
            }
            else {
                [SVProgressHUD dismiss];
                [wself showDialogWithTitle:@"Oops!" andMessage:@"No route found!"];
            }
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
        }];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"successful == true"];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:10];
    [fetchRequest setFetchLimit:10];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)showDialogWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

@end
