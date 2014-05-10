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

+(NSDictionary*) TWD97TM2toWGS84:(double )x :(double)y{
    double dx = 250000;
    double dy = 0;
    double lon0 = 121;
    double k0 = 0.9999;
    double a =  6378137.0;
    double b = 6356752.314245;
    double e = sqrt((1-(b*b)/(a*a)));
    //    double e = Math.sqrt((1-(b*b)/(a*a)));
    
    x -= dx;
    y -= dy;
    
    // Calculate the Meridional Arc
    double M = y/k0;
    
    // Calculate Footprint Latitude
    double mu = M/(a*(1.0 - pow(e, 2)/4.0 - 3*pow(e, 4)/64.0 - 5*pow(e, 6)/256.0));
    double e1 = (1.0 - pow((1.0 - pow(e, 2)), 0.5)) / (1.0 + pow((1.0 - pow(e, 2)), 0.5));
    
    double J1 = (3*e1/2 - 27*pow(e1, 3)/32.0);
    double J2 = (21*pow(e1, 2)/16 - 55*pow(e1, 4)/32.0);
    double J3 = (151*pow(e1, 3)/96.0);
    double J4 = (1097*pow(e1, 4)/512.0);
    
    double fp = mu + J1*sin(2*mu) + J2*sin(4*mu) + J3*sin(6*mu) + J4*sin(8*mu);
    // Calculate Latitude and Longitude
    
    double e2 = pow((e*a/b), 2);
    double C1 = pow(e2*cos(fp), 2);
    double T1 = pow(tan(fp), 2);
    double R1 = a*(1-pow(e, 2))/pow((1-pow(e, 2)*pow(sin(fp), 2)), (3.0/2.0));
    double N1 = a/pow((1-pow(e, 2)*pow(sin(fp), 2)), 0.5);
    
    double D = x/(N1*k0);
    //double drad = Math.PI/180.0;
    
    // lat
    double Q1 = N1*tan(fp)/R1;
    double Q2 = (pow(D, 2)/2.0);
    double Q3 = (5 + 3*T1 + 10*C1 - 4*pow(C1, 2) - 9*e2)*pow(D, 4)/24.0;
    double Q4 = (61 + 90*T1 + 298*C1 + 45*pow(T1, 2) - 3*pow(C1, 2) - 252*e2)*pow(D, 6)/720.0;
    double lat = RadiansToDegrees(fp - Q1*(Q2 - Q3 + Q4));
    // long
    double Q5 = D;
    double Q6 = (1 + 2*T1 + C1)*pow(D, 3)/6.0;
    double Q7 = (5 - 2*C1 + 28*T1 - 3*pow(C1, 2) + 8*pow(e2,2) + 24*pow(T1, 2))*pow(D, 5)/120.0;
    //    double lon = lon0 + (Q5 - Q6 + Q7)/cos(fp);
    double lon = lon0 + RadiansToDegrees((Q5 - Q6 + Q7)/cos(fp));
    
    NSDictionary*location = @{@"lat":@(lat),@"lng":@(lon)};
    return location;
}

double DegreesToRadians(double degrees)
{
    return degrees * M_PI / 180;
};

double RadiansToDegrees(double radians)
{
    return radians * 180 / M_PI;
};

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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)addBarrierPoints
{
    NSArray *points = [self pointsFromJSON];
    UIImage *image = [UIImage imageNamed:@"icon_0002_Vector-Smart-Object"];
    UIImage *newImage = [SCMainViewController imageWithImage:image scaledToSize:CGSizeMake(36, 59)];
    for (NSDictionary *dict in points) {
        NSDictionary *newPoint = [SCMainViewController TWD97TM2toWGS84:[dict[@"XLR_CORD"] doubleValue] :[dict[@"YLR_CORD"] doubleValue]];
        
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
