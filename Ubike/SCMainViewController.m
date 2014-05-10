//
//  SCMainViewController.m
//  Ubike
//
//  Created by Johnny on 5/10/14.
//  Copyright (c) 2014 wpsteak. All rights reserved.
//

#import "SCMainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface SCMainViewController ()

@property (weak, nonatomic) GMSMapView *mapView;

@end

@implementation SCMainViewController

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
    
    self.navigationController.title=@"Bikeable";
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    CGRect frame=CGRectMake(0, 0, 300, 300);
    self.mapView = [GMSMapView mapWithFrame:frame camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.view addSubview:self.mapView];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
    
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(51.5, -0.127);
    GMSMarker *london = [GMSMarker markerWithPosition:position];
    london.title = @"London";
    
    london.icon = [UIImage imageNamed:@"house"];
    london.map = self.mapView;
    
    PFQuery *query = [PFQuery queryWithClassName:@"BikeRoutes"];
//    [query whereKey:@"playerName" equalTo:@"Dan Stemkoski"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *routes, NSError *error) {
        if (!error) {
            NSLog(@"%d Routes", routes.count);
            for (PFObject *route in routes) {
                NSString *routeId=route.objectId;
                PFQuery *pointQuery = [PFQuery queryWithClassName:@"BikeRoutePoint"];
                [pointQuery whereKey:@"RoutesId" equalTo:routeId];
                [pointQuery findObjectsInBackgroundWithBlock:^(NSArray *points, NSError *error) {
                    for (PFObject *point in points) {
                        PFGeoPoint *po=point[@"location"];
                        
                        NSLog(@"Lat: %f", po.latitude);
                        NSLog(@"Lng: %f", po.longitude);
                        NSLog(@"------");
                    }
                    
                }];
                //test
                break;
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake(-33.85, 151.20)];
    [path addCoordinate:CLLocationCoordinate2DMake(-33.70, 151.40)];
    [path addCoordinate:CLLocationCoordinate2DMake(-33.73, 151.41)];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"pin-01.png"]];
    
    polyline.map=self.mapView;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
