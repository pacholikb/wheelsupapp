//
//  DiscoveryViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 15.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "DiscoveryViewController.h"

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle : @"Discovery"] ;
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];

    WHLMenuViewController *nav = (WHLMenuViewController *)self.navigationController;
    [nav.menu setItems:@[ nav.searchItem, nav.recentItem, nav.profileItem ]];
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle :@"Menu"
                                                                                style :UIBarButtonItemStyleBordered
                                                                               target :(WHLMenuViewController *)self.navigationController
                                                                               action :@selector( toggleMenu ) ] ;

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(updatePosts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    _expandedRows = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updatePosts];
}

- (void)updatePosts
{
    [[WHLNetworkManager sharedInstance].blogObjectManager getObjectsAtPathForRouteNamed:@"blogRoute" object:nil parameters:@{@"json" : @"get_recent_posts" } success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnClicked:(id)sender
{
    CGPoint point = [sender convertPoint:CGPointZero
                                  toView:self.tableView];
    BlogPost *post = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
    
    WHLSearchViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLSearchViewController" ];
    
    [ (WHLMenuViewController *)self.navigationController setViewControllers : @[ viewController ] animated : YES ] ;
    
    viewController.searchMode = place;
    viewController.toCode = [[post.tags firstObject] valueForKeyPath:@"title"];

}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:3];
    UIButton *btn = (UIButton *)[cell viewWithTag:4];
    
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *img = (UIImageView *)[cell viewWithTag:10];
    
    BlogPost *post = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    [img setImageWithURL:[NSURL URLWithString:post.image] placeholder:nil];
  
    if([_expandedRows containsObject:indexPath])
    {
        titleLabel.hidden = NO;
        dateLabel.hidden = NO;
        contentLabel.hidden = NO;
        btn.hidden = NO;
        
        titleLabel.text = post.title;
        dateLabel.text = [[post.categories firstObject] valueForKeyPath:@"title"];
    
        NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };
        
        NSData *data = [post.content dataUsingEncoding:NSUTF8StringEncoding];
        contentLabel.attributedText = [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
    }
    else
    {
        titleLabel.hidden = YES;
        dateLabel.hidden = YES;
        contentLabel.hidden = YES;
        btn.hidden = YES;
    }
    
}

#pragma mark - Table view data source

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
    static NSString *CellIdentifier = @"PostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_expandedRows containsObject:indexPath])
        [_expandedRows addObject:indexPath];
    else
        [_expandedRows removeObject:indexPath];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlogPost *post = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    NSData *data = [post.content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };
    
    CGFloat height;
    
    if([_expandedRows containsObject:indexPath])
        height = 280 + [[[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil] boundingRectWithSize:CGSizeMake(300, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    else
        height = 168;
    
    return height;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BlogPost" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

@end
