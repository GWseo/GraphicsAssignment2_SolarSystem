//
//  Planet.m
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/11/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import "Planet.h"

@implementation Planet

-(id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash ColorMode:(int)_mode{
    float colorIncrment = 0;
    float blue = 0.0;
    float red = 0.0;
    float green = 0.0;
    m_Scale = radius;
    m_Squash = squash;
    int mode = _mode;
    switch (mode) {
        case 0: //R->G
        case 1://R->B
            red= 1.0;
            break;
        case 2://G->R
        case 3://G->B
            green = 1.0;
            break;
        case 4://B->R
        case 5://B->G
            blue = 1.0;
            break;
        default:
            break;
    }
    
    colorIncrment= 1.0/stacks;
    
    if((self = [super init])){
        m_Stacks = stacks;
        m_Slices = slices;
        m_VertexData = nil;
        
        //Vertices
        Vertex *vPtr = m_VertexData = (Vertex*)malloc(sizeof(Vertex) *((m_Slices * 2 + 2) * (m_Stacks)));
        
        NSLog(@"%p %p.",vPtr,m_VertexData);
        
        unsigned int phiIdx, thetaIdx;
        
        //latitude
        for(phiIdx = 0; phiIdx < m_Stacks; phiIdx++){
            //the first circle.
            
            float phi0 = M_PI*((float)(phiIdx + 0)*(1.0/(float)(m_Stacks))-0.5);
            //the next, or second one.
            
            float phi1 = M_PI*((float)(phiIdx + 1)*(1.0/(float)(m_Stacks))-0.5);
            float cosPhi0 = cos(phi0);
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);
            
            float cosTheta, sinTheta;
            //longitude
            
            for(thetaIdx = 0 ; thetaIdx<m_Slices;thetaIdx++ ){
                //Increment along the longitude circle each "slice."
                float theta = 2.0*M_PI *((float)thetaIdx)* (1.0/(float)(m_Slices - 1));
                cosTheta = cos(theta);
                sinTheta = sin(theta);
                
                vPtr[0].Positions[0] = m_Scale*cosPhi0*cosTheta;
                vPtr[0].Positions[1] = m_Scale*sinPhi0*m_Squash;
                vPtr[0].Positions[2] = m_Scale*cosPhi0*sinTheta;

                vPtr[1].Positions[0] = m_Scale*cosPhi1*cosTheta;
                vPtr[1].Positions[1] = m_Scale*sinPhi1*m_Squash;
                vPtr[1].Positions[2] = m_Scale*cosPhi1*sinTheta;
                
                vPtr[0].Color[0]=red;
                vPtr[0].Color[1]=green;
                vPtr[0].Color[2]=blue;
                vPtr[0].Color[3]=1.0;
                vPtr[1].Color[0]=red;
                vPtr[1].Color[1]=green;
                vPtr[1].Color[2]=blue;
                vPtr[1].Color[3]=1.0;
                
                vPtr += 2;
                
            }
            switch (mode) {
                case 0: //R->G
                    green+=colorIncrment;
                    red-=colorIncrment;
                    break;
                case 1://R->B
                    blue+=colorIncrment;
                    red-=colorIncrment;
                    break;
                case 2://G->R
                    green -=colorIncrment;
                    red +=colorIncrment;
                    break;
                case 3://G->B
                    green -=colorIncrment;
                    blue +=colorIncrment;
                    break;
                case 4://B->R
                    blue-=colorIncrment;
                    red+=colorIncrment;
                    break;
                case 5://B->G
                    blue-=colorIncrment;
                    green+=colorIncrment;
                    break;
                default:
                    break;
            }
        }
    }
    
    return self;
}

-(Vertex *)getVertexMatrix
{
    return m_VertexData;
}

@end
