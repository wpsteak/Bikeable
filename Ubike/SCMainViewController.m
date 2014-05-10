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
#import "SCTool.h"

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
    self.view = self.mapView;
//    [self.view addSubview:self.mapView];
    
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
    [self addBarrierPoints];
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

- (NSArray *)pointsFromJSON {
    // Retrieve local JSON file called example.json
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"points" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    
    NSError *error = nil;
    
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    // Create an Objective-C object from JSON Data
    
    NSArray *JSONObject = [NSJSONSerialization
                     JSONObjectWithData:JSONData
                     options:NSJSONReadingAllowFragments
                     error:&error];
    
    return (NSArray *)JSONObject;
}



- (void)addBarrierPoints
{
    NSArray *points = [self pointsFromJSON];
    UIImage *image = [UIImage imageNamed:@"icon_0002_Vector-Smart-Object"];
    UIImage *newImage = [SCTool imageWithImage:image scaledToSize:CGSizeMake(36, 59)];
    for (NSDictionary *dict in points) {
        NSDictionary *newPoint = [SCTool TWD97TM2toWGS84:[dict[@"XLR_CORD"] doubleValue] :[dict[@"YLR_CORD"] doubleValue]];
        
        GMSMarker *marker;
        marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([newPoint[@"lat"] doubleValue], [newPoint[@"lng"] doubleValue])];
        
        marker.icon = newImage;
        marker.groundAnchor = CGPointMake(0.5f, 1.0f);
        marker.flat = YES;
        marker.map = self.mapView;
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
    polyline.strokeWidth=3;
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
    
    PFGeoPoint *tpos=[self toPoint:JSONObject[@"routes"][0][@"legs"][0][@"start_location"]];
    PFGeoPoint *tpoe=[self toPoint:JSONObject[@"routes"][0][@"legs"][0][@"end_location"]];
    
    [arr addObject:tpos];
    for (NSDictionary* step in JSONObject[@"routes"][0][@"legs"][0][@"steps"]) {
        PFGeoPoint *pos=[self toPoint:step[@"start_location"]];
        PFGeoPoint *poe=[self toPoint:step[@"end_location"]];
        
        [arr addObject:pos];
        [arr addObject:poe];
    }
    [arr addObject:tpoe];
    
    return arr;
}

-(PFGeoPoint *) toPoint:(NSDictionary *)dic
{
    PFGeoPoint *po=[[PFGeoPoint alloc] init];
    po.latitude=[dic[@"lat"] doubleValue];
    po.longitude=[dic[@"lng"] doubleValue];
    return po;
}

@end
