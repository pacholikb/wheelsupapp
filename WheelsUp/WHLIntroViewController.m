//
//  WHLIntroViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 28.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLIntroViewController.h"
#import "SVProgressHUD.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568  )

@interface WHLIntroViewController ()

@end

@implementation WHLIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(IS_WIDESCREEN){

        (_image1.image = [UIImage imageNamed:@"instr1_5s.png"]);

        (_image2.image = [UIImage imageNamed:@"instr2_5s.png"]);

        (_image3.image = [UIImage imageNamed:@"instr3_5s.png"]);
        
    }
    else {
        
        (_image1.image = [UIImage imageNamed:@"Instr1.png"]);
        
        (_image2.image = [UIImage imageNamed:@"instr2.png"]);
        
        (_image3.image = [UIImage imageNamed:@"instr3.png"]);
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [SVProgressHUD showWithStatus:@"Configuring..." maskType:SVProgressHUDMaskTypeBlack];
    [self performSelector:@selector(populateDB:) withObject:[RKObjectManager sharedManager].managedObjectStore.persistentStoreCoordinator afterDelay:0.2];
    //[self populateDB:[RKObjectManager sharedManager].managedObjectStore.persistentStoreCoordinator];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    if(!_pageControlBeingUsed) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        
        CGFloat alpha;
        if(page == 2)
            alpha = 1.0;
        else
            alpha = 0.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            _skipButton.alpha = alpha;
        }];
        
    }
}

- (void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(960, _scrollView.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quitSlideshow:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"intro"];
    [defaults synchronize];
    
    UIViewController *firstController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WHLMenuViewController"];
    self.view.window.rootViewController = firstController;

}

- (IBAction)changePage {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    CGFloat alpha;
    if(self.pageControl.currentPage == 2)
        alpha = 1.0;
    else
        alpha = 0.0;
    
    [UIView animateWithDuration:0.4 animations:^{
        _skipButton.alpha = alpha;
    }];
    
    _pageControlBeingUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
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
   
    //first search
    filePath = [[NSBundle mainBundle] pathForResource:@"filtered list small" ofType:@"csv"];
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
                    
                    NSString *string2=[lineComponents objectAtIndex:2];
                    
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
                    [fetchRequest setEntity:entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iata ==[c] %@",string2];
                    [fetchRequest setPredicate:predicate];
                    NSError *error;
                    NSManagedObject *object = [[context executeFetchRequest:fetchRequest error:&error] firstObject];
                    
                    if(object) {
                        [object setValue:[NSNumber numberWithBool:YES] forKey:@"firstSearch"];
                    }
                    
                    count++;
                    if(count>=100){
                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        count=0;
                        
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
    [SVProgressHUD dismiss];
}


@end
