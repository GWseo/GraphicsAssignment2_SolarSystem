//
//  Vertex.h
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/12/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Vertex <NSObject>
typedef struct{
    float Positions[3];
    float Color[4];
}Vertex;
@end
