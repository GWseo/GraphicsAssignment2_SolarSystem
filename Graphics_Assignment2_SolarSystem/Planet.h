//
//  Planet.h
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/11/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>

typedef struct{
    float Positions[3];
    float Color[4];
}Vertex;

@interface Planet : NSObject
{
@private
    Vertex *m_VertexData;    
    GLint m_Stacks, m_Slices;
    GLfloat m_Scale;
    GLfloat m_Squash;
}

- (Vertex *)getVertexMatrix;
-(id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash ColorMode:(int)_mode;

@end
