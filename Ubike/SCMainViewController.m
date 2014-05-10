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
@property (strong, nonatomic) NSMutableArray *routeArray;

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
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.041294
                                                            longitude:121.557953
                                                                 zoom:14];
    CGRect frame=self.view.bounds;
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
    
    [self loadRoutePoints];
    
    

    // Do any additional setup after loading the view from its nib.
}

-(void) loadRoutePoints
{
    self.routeArray= [[NSMutableArray alloc] init];
    
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
                    NSMutableArray *routePoints=[[NSMutableArray alloc]init];
                    for (PFObject *point in points) {
                        PFGeoPoint *po=point[@"location"];
                        [routePoints addObject:po];
//                        NSLog(@"Lat: %f", po.latitude);
//                        NSLog(@"Lng: %f", po.longitude);
//                        NSLog(@"------");
                    }
                    [self.routeArray addObject:routePoints];
                    [self drawRoutes];
                }];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) drawRoutes
{
    int i=0;
    for (NSArray* route in self.routeArray) {
        
        GMSMutablePath *path = [GMSMutablePath path];
        for (PFGeoPoint* po in route) {
            [path addCoordinate:CLLocationCoordinate2DMake(po.latitude, po.longitude)];
        }
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        if (i%2) {
            polyline.strokeColor=[UIColor colorWithRed:0.492721F green:0.792157F blue:0.596751F alpha:1.0F];
        }else{
            polyline.strokeColor=[UIColor colorWithRed:0.620210F green:0.349216F blue:0.792157F alpha:1.0F];
        }
        polyline.strokeWidth=3;
        polyline.map=self.mapView;
        i++;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
