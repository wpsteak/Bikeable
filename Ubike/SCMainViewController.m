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

// http://maps.googleapis.com/maps/api/directions/json?origin=25.038450,121.539915&destination=taipei101&sensor=false

@interface SCMainViewController ()

@property (strong, nonatomic) GMSMapView *mapView;
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
    
    self.title=@"Bikeable";
    
    [self totaipei101];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:25.038450
                                                            longitude:121.539915
                                                                 zoom:14];
    CGRect frame=self.view.bounds;
//    CGRect frame=CGRectMake(0, 0, 300, 300);
    self.mapView = [GMSMapView mapWithFrame:frame camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.view insertSubview:self.mapView atIndex:0];
//    self.view=self.mapView;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(25.038450, 121.539915);
    marker.title = @"Start";
    marker.map = self.mapView;
    
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(51.5, -0.127);
    GMSMarker *london = [GMSMarker markerWithPosition:position];
    london.title = @"London";
    
    london.icon = [UIImage imageNamed:@"house"];
    london.map = self.mapView;
    
    [self loadRoutePoints];
    [self drawtotaipei101];
    
    [self bikeshop];

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

-(void) drawtotaipei101
{
    NSMutableArray * totaipei101arr=[self totaipei101];
    GMSMutablePath *path = [GMSMutablePath path];
    for (PFGeoPoint* po in totaipei101arr) {
        [path addCoordinate:CLLocationCoordinate2DMake(po.latitude, po.longitude)];
    }
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor=[UIColor colorWithRed:0.792157F green:0.046228F blue:0.055991F alpha:1.0F];
    polyline.strokeWidth=5;
    polyline.map=self.mapView;
}


-(NSMutableArray *) totaipei101
{
    // Retrieve local JSON file called example.json
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dataTo101" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    
    NSError *error = nil;
    
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    // Create an Objective-C object from JSON Data
    
    id JSONObject = [NSJSONSerialization
                     JSONObjectWithData:JSONData
                     options:NSJSONReadingAllowFragments
                     error:&error];

//    JSONObject[@"routes"][0][@"legs"][0][@"start_location"];
//    end_location
    //    JSONObject[@"routes"][0][@"legs"][0][@"steps"][i][@"start_location"];
    //    JSONObject[@"routes"][0][@"legs"][0][@"steps"][i][@"end_location"];
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
//    JSONObject[@"routes"][0][@"legs"][0][@"steps"][i][@"start_location"];
    
//    PFGeoPoint *tpos=[self toPoint:JSONObject[@"routes"][0][@"legs"][0][@"start_location"]];
//    PFGeoPoint *tpoe=[self toPoint:JSONObject[@"routes"][0][@"legs"][0][@"end_location"]];
//    
    
    
    for (NSDictionary* legs in JSONObject[@"routes"][0][@"legs"]) {
        PFGeoPoint *tpos=[self toPoint:legs[@"start_location"]];
        PFGeoPoint *tpoe=[self toPoint:legs[@"end_location"]];
        [arr addObject:tpos];
        for (NSDictionary* step in legs[@"steps"]) {
            PFGeoPoint *pos=[self toPoint:step[@"start_location"]];
            PFGeoPoint *poe=[self toPoint:step[@"end_location"]];
            
            [arr addObject:pos];
            [arr addObject:poe];
        }
        [arr addObject:tpoe];
    }
    return arr;
}

-(PFGeoPoint *) toPoint:(NSDictionary *)dic
{
    PFGeoPoint *po=[[PFGeoPoint alloc] init];
    po.latitude=[dic[@"lat"] doubleValue];
    po.longitude=[dic[@"lng"] doubleValue];
    return po;
}


-(NSMutableArray *) bikeshop
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bikeshop" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    
    NSError *error = nil;
    
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    // Create an Objective-C object from JSON Data
    
    id JSONObject = [NSJSONSerialization
                     JSONObjectWithData:JSONData
                     options:NSJSONReadingAllowFragments
                     error:&error];

    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    for (NSDictionary* shop in JSONObject) {
        PFObject *routes = [PFObject objectWithClassName:@"BikeShop"];
        routes[@"name"]=shop[@"name"];
        routes[@"address"]=shop[@"address"];
        routes[@"location"]=[PFGeoPoint geoPointWithLatitude:[shop[@"latitude"] doubleValue] longitude:[shop[@"longitude"] doubleValue]];
        [arr addObject:routes];
    }
    
    return arr;
}


@end
