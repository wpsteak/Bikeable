//
//  SCTool.m
//  Ubike
//
//  Created by Prince on 5/10/14.
//  Copyright (c) 2014 wpsteak. All rights reserved.
//

#import "SCTool.h"

@implementation SCTool

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


@end
