//
//  SolarSystemViewController.m
//  Graphics_Assignment2_SolarSystem
//
//  Created by gyuwon_mac on 5/11/14.
//  Copyright (c) 2014 pnu. All rights reserved.
//

#import "SolarSystemViewController.h"

@interface SolarSystemViewController (){
    unsigned int ViewMode;
    GLuint _SunVertexBuffer;
    GLuint _EarthVertexBuffer;
    GLuint _CameraVertexBuffer;
    GLuint _PlutoVertexBuffer;
    
    float _rotation;
    
    Planet* Sun;
    Planet* Earth;
    Planet* Camera;
    Planet* Pluto;
    
    int stack;
    int slice;
}

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation SolarSystemViewController
@synthesize context = _context;
@synthesize effect = _effect;
- (IBAction)EarthSpeeldScroll:(UISlider *)sender {
}
- (IBAction)PlutoSpeedScroll:(UISlider *)sender {
}
- (IBAction)CameraSpeedScroll:(UISlider *)sender {
}
- (IBAction)ChangeViewMode:(UIButton *)sender {
    ViewMode +=1;
    ViewMode %=5;
    NSLog(@"ViewMode : %d",ViewMode);
}

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
    NSLog(@"ViewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(!self.context){
        NSLog(@"Fail To create ES context");
    }
    GLKView *view = (GLKView*)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    ViewMode = 0;
    [self setupGL];
}

- (void)viewDidUnload{
    [self tearDownGL];
    [super viewDidUnload];
    
    if([EAGLContext currentContext] == self.context){
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)tearDownGL{
    
    glDeleteBuffers(1, &_SunVertexBuffer);
    glDeleteBuffers(2, &_EarthVertexBuffer);
    glDeleteBuffers(3, &_PlutoVertexBuffer);
    glDeleteBuffers(4, &_CameraVertexBuffer);
    self.effect= nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupGL{
    NSLog(@"setupGL");
    [EAGLContext setCurrentContext:self.context];
    stack = 50;
    slice = 50;
    Sun     = [[Planet alloc]init:stack slices:slice radius:2.0 squash:1.0 ColorMode:1];
    Earth   = [[Planet alloc]init:stack slices:slice radius:1.0 squash:1.0 ColorMode:0];
    Pluto   = [[Planet alloc]init:stack slices:slice radius:1.5 squash:1.0 ColorMode:3];
    Camera  = [[Planet alloc]init:stack slices:slice radius:0.5 squash:1.0 ColorMode:5];
    
    self.effect = [[GLKBaseEffect alloc]init];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    glGenBuffers(1, &_SunVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _SunVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((slice+1)*2*(stack-1)+2)*sizeof(Vertex), [Sun getVertexMatrix], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_EarthVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _EarthVertexBuffer );
    glBufferData(GL_ARRAY_BUFFER, ((slice+1)*2*(stack-1)+2)*sizeof(Vertex), [Earth getVertexMatrix], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_PlutoVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _PlutoVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((slice+1)*2*(stack-1)+2)*sizeof(Vertex), [Pluto getVertexMatrix], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_CameraVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _CameraVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((slice+1)*2*(stack-1)+2)*sizeof(Vertex), [Camera getVertexMatrix], GL_STATIC_DRAW);
    
}


#pragma mark - GLKViewControllerDelegate

-(void)update{
        _rotation += 5*self.timeSinceLastUpdate;
    //NSLog(@"1234");
}

#pragma mark - GLKViewDelegate

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    switch (ViewMode) {
        case 0:
            //Right Bottom
            glViewport(0, 0, self.view.window.screen.scale * view.frame.size.width/2, self.view.window.screen.scale * view.frame.size.height/2);
            [self PlutoView];
            //Left Bottom
            glViewport(self.view.window.screen.scale * view.frame.size.width/2, 0, self.view.window.screen.scale * view.frame.size.width/2, self.view.window.screen.scale * view.frame.size.height/2);
            [self CameraView];
            //Right Top
            glViewport(0, self.view.window.screen.scale * view.frame.size.height/2, self.view.window.screen.scale * view.frame.size.width/2, self.view.window.screen.scale * view.frame.size.height/2);
            [self SunView];
            //Left Top
            glViewport(self.view.window.screen.scale * view.frame.size.width/2, self.view.window.screen.scale * view.frame.size.height/2, self.view.window.screen.scale * view.frame.size.width/2, self.view.window.screen.scale * view.frame.size.height/2);
            [self EarthView];
            break;
        case 1:
            [self SunView];
            break;
        case 2:
            [self EarthView];
        case 3:
            [self PlutoView];
        case 4:
            [self CameraView];
        default:
            [self SunView];
            break;
    }
    
}
-(void)execute{
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Positions));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Color));
    glDrawArrays(GL_LINE_STRIP, 0, ((slice+1)*2*(stack-1)+2));
    
}
-(void)SunView{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;

    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    //_rotation += 90* self.timeSinceLastUpdate;
    
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0, 0.0, 1.0);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, _SunVertexBuffer);
    [self execute];
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0, 1.0, 1.0);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, cosf(_rotation), 0.0, sinf(_rotation));
    self.effect.transform.modelviewMatrix = modelViewMatrix2;
    
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _EarthVertexBuffer);
    [self execute];
    
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 3.0f, 1.0f, 0.0);
    self.effect.transform.modelviewMatrix = modelViewMatrix2;
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _PlutoVertexBuffer);
    [self execute];
    
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 3.0f, 1.0f, 0.0);
    self.effect.transform.modelviewMatrix = modelViewMatrix2;
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _CameraVertexBuffer);
    [self execute];
    

}

-(void)EarthView{
    
}
-(void)PlutoView{
    
}
-(void)CameraView{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw : %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume : %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume : %f", self.timeSinceLastResume);
    self.paused = !self.paused;
}
@end
