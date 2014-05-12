//
//  Axis.h
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/12/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vertex.h"



@interface Axis : NSObject
{
@private
    Vertex *m_VertexData;
    GLfloat m_Scale;
}
-(Vertex*)getVertexMatrix;
-(id)init:(GLint)radius;
@end
