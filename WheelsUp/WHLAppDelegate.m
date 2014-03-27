//
//  WHLAppDelegate.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-07.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//


#import "WHLAppDelegate.h"
#import "REMenu.h"
#import "WHLNetworkManager.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"

@implementation WHLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"WheelsUpModel" ofType:@"momd"]];

    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSArray * searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [searchPaths objectAtIndex:0];
    NSPersistentStore * persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:[NSString stringWithFormat:@"%@/CoreData.sqlite", documentPath] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    
    if(!persistentStore){
        NSLog(@"Failed to add persistent store: %@", error);
    }
    
    [managedObjectStore createManagedObjectContexts];
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/javascript"];
    
    [[WHLNetworkManager sharedInstance] configureObjectManager:managedObjectStore];

    //Parse
    [Parse setApplicationId:@"mCkWu97Ihyq15GatzIG8j4qznXjHj6Oazw8EiylD"
                  clientKey:@"ysMXari68iDq8bSnXU85i44W86mEcuxaZHYoJBjx"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    //Flurry
    
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"57D3B6HG74GPT4SQWM7W"];
    
    
    //Status Bar

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    //Navigation Bar
    NSMutableDictionary* titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
    
    [titleBarAttributes setValue: [ UIColor lightGrayColor] forKey: NSForegroundColorAttributeName];
     
    [[UINavigationBar appearance] setTitleTextAttributes: titleBarAttributes];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:@"initialized"]) {
        [self populateDB:managedObjectStore.persistentStoreCoordinator];
        [defaults setBool:YES forKey:@"initialized"];
        [defaults synchronize];
    }
    
    UIViewController *firstController;

    if([defaults boolForKey:@"intro"])
        firstController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WHLMenuViewController"];
    else
        firstController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"introViewController"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = firstController;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
   

    
    return YES;
}

-(void)populateDB :(NSPersistentStoreCoordinator *) coordinator
{
    NSManagedObjectContext *context;
    if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"csv"];
    if (filePath) {
        NSString * myText = [[NSString alloc]
                             initWithContentsOfFile:filePath
                             encoding:NSUTF8StringEncoding
                             error:nil];
        if (myText) {
            __block int count = 0;
            
            
            [myText enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
      
                NSArray *lineComponents=[line componentsSeparatedByString:@","];
                if(lineComponents){
                 
                    NSString *string0=[lineComponents objectAtIndex:0];
                    
                    if([string0 isEqualToString:@"\"City\""]) {
            
                        NSString *string1=[lineComponents objectAtIndex:1];
                        NSString *string2=[lineComponents objectAtIndex:2];
                        NSString *string3=[lineComponents objectAtIndex:5];
                        NSManagedObject *object=[NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
                        [object setValue:[string1 stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"name"];
                        [object setValue:[string2 stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"iata"];
                        [object setValue:[string3 stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"country"];
                        NSError *error;
                        count++;
                        if(count>=1000){
                            if (![context save:&error]) {
                                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                            }
                            count=0;
                            
                        }
                    }
                    
                }
                
                
                
            }];
            NSLog(@"done importing");
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
        }  
    }
    
    //filter
    filePath = [[NSBundle mainBundle] pathForResource:@"filtered city list" ofType:@"csv"];
    if (filePath) {
        NSString * myText = [[NSString alloc]
                             initWithContentsOfFile:filePath
                             encoding:NSUTF8StringEncoding
                             error:nil];
        if (myText) {
            __block int count = 0;
            
            
            [myText enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
                
                NSArray *lineComponents=[line componentsSeparatedByString:@","];
                if(lineComponents){
                    
                    NSString *string0=[lineComponents objectAtIndex:0];
                    
                    if([string0 isEqualToString:@"City"]) {
                        
                        NSString *string1=[lineComponents objectAtIndex:1];
                        NSString *string2=[lineComponents objectAtIndex:2];
                        
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
                        [fetchRequest setEntity:entity];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iata ==[c] %@",string2];
                        [fetchRequest setPredicate:predicate];
                        NSError *error;
                        NSManagedObject *object = [[context executeFetchRequest:fetchRequest error:&error] firstObject];
                        
                        if(object) {
                            [object setValue:[NSNumber numberWithBool:YES] forKey:@"filtered"];
                        }
                        
                        count++;
                        if(count>=100){
                            if (![context save:&error]) {
                                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                            }
                            count=0;
                            
                        }
                    }
                    
                }
                
                
                
            }];
            NSLog(@"done importing");
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
        }  
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSession.activeSession handleDidBecomeActive];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [FBSession.activeSession close];
}

@end
