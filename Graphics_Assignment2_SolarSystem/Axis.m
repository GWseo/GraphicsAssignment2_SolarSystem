//
//  Axis.m
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/12/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import "Axis.h"

@implementation Axis

static const float frame[7*6]={
    1.0f, 0.0f, 0.0f, 1.0f,1.0f,1.0f,1.0f,
    -1.0f, 0.0f, 0.0f, 1.0f,1.0f,1.0f,1.0f,
    
    0.0f, 1.0f, 0.0f,1.0f,1.0f,1.0f,1.0f,
    0.0f, -1.0f, 0.0f,1.0f,1.0f,1.0f,1.0f,
    
    0.0f, 0.0f, 1.0f,1.0f,0.0f,0.0f,1.0f,
    0.0f, 0.0f, -1.0f,1.0f,0.0f,0.0f,1.0f,
};


-(id)init:(GLint)radius {
    m_Scale = radius;
    if((self=[super init])){
        m_VertexData=nil;
        Vertex* vPtr = m_VertexData = (Vertex*)malloc(sizeof(Vertex)*6);
        
        unsigned int Idx;
        for(Idx =0 ; Idx < 6 ; Idx++){
            vPtr[Idx].Positions[0]=m_Scale*frame[Idx*7+0];
            vPtr[Idx].Positions[1]=m_Scale*frame[Idx*7+1];
            vPtr[Idx].Positions[2]=m_Scale*frame[Idx*7+2];
            vPtr[Idx].Color[0]=frame[Idx*7+3];
            vPtr[Idx].Color[1]=frame[Idx*7+4];
            vPtr[Idx].Color[2]=frame[Idx*7+5];
            vPtr[Idx].Color[3]=frame[Idx*7+6];
        }
    }
    return self;
}
-(Vertex *)getVertexMatrix{
    return m_VertexData;
}

@end
