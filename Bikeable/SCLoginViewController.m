//
//  SCLoginViewController.m
//  Ubike
//
//  Created by Prince on 5/10/14.
//  Copyright (c) 2014 wpsteak. All rights reserved.
//

#import "SCLoginViewController.h"
#import "MovesAPI.h"
#import "NSObject+LogProperties.h"
#import <Parse/Parse.h>

@interface SCLoginViewController ()

@end

@implementation SCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)loginWithMoves:(UIButton *)sender
{
    if (sender.selected) {
        [[MovesAPI sharedInstance] logout];
        sender.selected = NO;
        [sender setBackgroundColor:[UIColor colorWithRed:0/255.0 green:212/255.0 blue:90/255.0 alpha:1]];
//        [self.indicatorView stopAnimating];
    } else {
        [[MovesAPI sharedInstance] authorizationWithViewController:self
                                                           success:^{
                                                               sender.selected = YES;
                                                               [sender setBackgroundColor:[UIColor colorWithRed:237/255.0 green:103/255.0 blue:214/255.0 alpha:1]];
//                                                               self.resultTextView.text = @"Auth successed!";
//                                                               [self.indicatorView stopAnimating];
                                                           } failure:^(NSError *error) {
                                                               sender.selected = NO;
                                                               [sender setBackgroundColor:[UIColor colorWithRed:0/255.0 green:212/255.0 blue:90/255.0 alpha:1]];
//                                                               self.resultTextView.text = @"Auth failed!";
//                                                               [self.indicatorView stopAnimating];
                                                           }];
    }
}


#pragma mark - General

- (IBAction)requestProfile:(id)sender {
    [[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
        
//        self.resultTextView.text = [user logProperties];
//        [self.indicatorView stopAnimating];
    } failure:^(NSError *error) {

    }];
}

- (IBAction)requestDayStorylineAction:(id)sender {
    
//    [[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
//       user
//    } failure:^(NSError *error) {
//        
//    }];
    [[MovesAPI sharedInstance] getWeekStoryLineByDate:[NSDate date]
                                          trackPoints:YES
                                              success:^(NSArray *storyLines) {
                                                  [self printStoryLine:storyLines];
                                              }
                                              failure:^(NSError *error) {
                                                  
                                              }];
}

- (void)printStoryLine:(NSArray *)storyLines {
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"storyLines count: %lu\n", (unsigned long)storyLines.count];
    
    NSMutableArray *cyclingCollection = [NSMutableArray array];
    
    for (MVStoryLine *storyLine in storyLines) {
        NSMutableArray *cyclingTrackPoints = [NSMutableArray array];
        
        for(MVSegment *segment in storyLine.segments) {
            for(MVActivity *activity in segment.activities) {
                if ([@"cycling" isEqualToString:activity.activity]) {
                    NSLog(@"%lu",(unsigned long)[activity.trackPoints count]);
                    for(MVTrackPoint *trackPoint in activity.trackPoints) {
                        NSNumber *lat = [NSNumber numberWithFloat:trackPoint.lat];
                        NSNumber *lon = [NSNumber numberWithFloat:trackPoint.lon];
                        
                        NSArray *trackPoint = @[lat, lon];
                        [cyclingTrackPoints addObject:trackPoint];
                    }
                }
            }
        }
        
        if ([cyclingTrackPoints count] > 0) {
            [cyclingCollection addObject:cyclingTrackPoints];
        }
//        NSLog(@"%@", cyclingCollection);
        
        for (NSArray* routeRaw in cyclingCollection) {
            
            for (NSArray* po in routeRaw) {
                NSLog(@"Lat: %@", po[0]);
                NSLog(@"Lng: %@", po[1]);
                NSLog(@"----");
            }
            NSLog(@"============");
        }
        
    }
}

-(void) saveRoutesHard:(NSArray *)cyclingCollection
{
    PFUser *user = [PFUser user];
    user.username = @"Prince";
    user.password = @"1234";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            int i=1;
            for (NSArray* routeRaw in cyclingCollection) {
                
                PFObject *routes = [PFObject objectWithClassName:@"BikeRoutes"];
                //        routes[@"UserId"] =
                
                routes[@"RoutesName"] = [NSString stringWithFormat:@"Routes%d", i];
                i++;
                routes[@"userId"]=user.objectId;
                [routes saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error)
                    {
                        for (NSArray* po in routeRaw) {
                            NSNumber *lat=po[0];
                            NSNumber *lng=po[1];
                            PFObject *point = [PFObject objectWithClassName:@"BikeRoutePoint"];
                            point[@"RoutesId"] = routes.objectId;
                            point[@"location"] = [PFGeoPoint geoPointWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                            [point saveInBackground];
                        }
                    }
                }];
                
            }
        }
    }];
}



@end
