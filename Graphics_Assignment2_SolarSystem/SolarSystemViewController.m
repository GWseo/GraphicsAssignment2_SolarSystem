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
    GLuint _SatelliteVertexBuffer;
    GLuint _PlutoVertexBuffer;
    GLuint _AxisVertexBuffer;
    
    float _rotation;
    float _EarthRotation;
    float _PlutoRotation;
    float _SatelliteRotation;
    float _SatelliteRevolution;
    
    float _plutoX;
    float _plutoY;
    float _earthR;
    float _plutoR;
    
    float _sunViewR;
    float _earthViewR;
    float _satelliteViewR;
    float _plutoViewR;
    
    bool shift;
    
    Planet* Sun;
    Planet* Earth;
    Planet* Satellite;
    Planet* Pluto;
    
    Axis* mAxis;
    
    int stack;
    int slice;
}

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation SolarSystemViewController
@synthesize context = _context;
@synthesize effect = _effect;

- (IBAction)EarthSpeedScroll:(UISlider *)sender {
    _EarthRotation = [sender value];
}
- (IBAction)PlutoSpeedScroll:(UISlider *)sender {
    _PlutoRotation = [sender value];
}
- (IBAction)CameaSpeedScroll:(UISlider *)sender {
    _SatelliteRotation = [sender value];
}

- (IBAction)ChangeViewMode:(UIButton *)sender {
    ViewMode +=1;
    ViewMode %=5;
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
    _EarthRotation = 1.0;
    _PlutoRotation = 1.0;
    _SatelliteRotation = 1.0;
    _SatelliteRevolution = 0.0;
    _plutoX = 90000;
    _plutoY = 62500;
    _earthR = 10000;
    _sunViewR = 25.0;
    _earthViewR = 10.0;
    _satelliteViewR = 5.0;
    _plutoViewR = 5.0;
    stack = 100;
    slice = 100;
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
    glDeleteBuffers(1, &_EarthVertexBuffer);
    glDeleteBuffers(1, &_PlutoVertexBuffer);
    glDeleteBuffers(1, &_SatelliteVertexBuffer);
    glDeleteBuffers(1, &_AxisVertexBuffer);
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

    Sun     = [[Planet alloc]init:stack slices:slice radius:_sunViewR squash:1.0 ColorMode:1];
    Earth   = [[Planet alloc]init:stack slices:slice radius:_earthViewR squash:1.0 ColorMode:0];
    Pluto   = [[Planet alloc]init:stack slices:slice radius:_plutoViewR squash:1.0 ColorMode:3];
    Satellite  = [[Planet alloc]init:stack slices:slice radius:_satelliteViewR squash:1.0 ColorMode:2];
    mAxis = [[Axis alloc] init:30.0];
    
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
    
    glGenBuffers(1, &_SatelliteVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _SatelliteVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, ((slice+1)*2*(stack-1)+2)*sizeof(Vertex), [Satellite getVertexMatrix], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_AxisVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _AxisVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 6*sizeof(Vertex), [mAxis getVertexMatrix], GL_STATIC_DRAW);
}


#pragma mark - GLKViewControllerDelegate

-(void)update{
    _rotation += 25*self.timeSinceLastUpdate;
    _SatelliteRevolution += 30*self.timeSinceLastUpdate;
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
            break;
        case 3:
            [self PlutoView];
            break;
        case 4:
            [self CameraView];
            break;
        default:
            NSLog(@"Error haha");
            break;
    }
}
-(void)execute :(GLKMatrix4)ModelViewMatrix{
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Positions));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Color));
    glDrawArrays(GL_LINE_STRIP, 0, ((slice+1)*2*(stack-1)+2));
    
    //Draw Axis
    self.effect.transform.modelviewMatrix = ModelViewMatrix;
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _AxisVertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Positions));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, Color));
    glDrawArrays(GL_LINES, 0, 6);
    
}
-(void)buildUniverse{
    GLKMatrix4 baseMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    GLKMatrix4 sunModelViewMatrix = GLKMatrix4Translate(baseMatrix,0.0f, 0.0f, 0.0f);
    GLKMatrix4 earthModelViewMatrix;
    GLKMatrix4 satelliteModelViewMatrix;
    GLKMatrix4 plutoModelViewMatrix;
    sunModelViewMatrix = GLKMatrix4Rotate(sunModelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0, 1.0, 0.0);
    
    self.effect.transform.modelviewMatrix = sunModelViewMatrix;
    
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _SunVertexBuffer);
    [self execute:sunModelViewMatrix];
    earthModelViewMatrix = baseMatrix;
    
    earthModelViewMatrix = GLKMatrix4Rotate(earthModelViewMatrix, GLKMathDegreesToRadians((_rotation)*_EarthRotation+180), 0.0, 1.0, 0.0);
    earthModelViewMatrix = GLKMatrix4Translate(earthModelViewMatrix, 0.0, 0.0, sqrtf(_earthR));
    earthModelViewMatrix = GLKMatrix4Rotate(earthModelViewMatrix, GLKMathDegreesToRadians(-15), 0.0, 0.0, 1.0);
    
    satelliteModelViewMatrix=earthModelViewMatrix;
    
    earthModelViewMatrix = GLKMatrix4Rotate(earthModelViewMatrix, GLKMathDegreesToRadians( (_rotation)*_EarthRotation*3), 0.0, 1.0, 0.0);
    self.effect.transform.modelviewMatrix = earthModelViewMatrix;
    
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _EarthVertexBuffer);
    [self execute:earthModelViewMatrix];
    
    satelliteModelViewMatrix = GLKMatrix4Rotate(satelliteModelViewMatrix,GLKMathDegreesToRadians(_SatelliteRevolution), 0.0, 0.0, 1.0);
    
    satelliteModelViewMatrix = GLKMatrix4Rotate(satelliteModelViewMatrix, GLKMathDegreesToRadians(_rotation*_SatelliteRotation*360/25), 0.0, 1.0, 0.0);
    satelliteModelViewMatrix = GLKMatrix4Translate(satelliteModelViewMatrix, _earthViewR+10.0f, 0.0, 0.0);
    self.effect.transform.modelviewMatrix = satelliteModelViewMatrix;
    
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _SatelliteVertexBuffer);
    [self execute:satelliteModelViewMatrix];
    float PlutoDegree = GLKMathDegreesToRadians((_rotation)*_PlutoRotation/7+90);
    // pluto must allways look at earth center...? how???
    float R = sqrtf((_plutoX*cosf(PlutoDegree)*cosf(PlutoDegree))+_plutoY*sinf(PlutoDegree)*sinf(PlutoDegree));
    
    plutoModelViewMatrix = baseMatrix;
    
    plutoModelViewMatrix = GLKMatrix4Rotate(plutoModelViewMatrix, PlutoDegree, 0.0, 1.0, 0.0);
    plutoModelViewMatrix = GLKMatrix4Translate(plutoModelViewMatrix, 0.0, 0.0, R);
    plutoModelViewMatrix = GLKMatrix4Rotate(plutoModelViewMatrix, PlutoDegree*7, 0.0, 1.0, 0.0);
    self.effect.transform.modelviewMatrix = plutoModelViewMatrix;
    
    [self.effect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _PlutoVertexBuffer);
    [self execute:plutoModelViewMatrix];
}
-(void)SunView{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, _sunViewR, 1000.0f);
   
    self.effect.transform.projectionMatrix = projectionMatrix;
    [self buildUniverse];
}

-(void)EarthView{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    
    //View Must be Multiply as Stack wise
    GLKMatrix4 BaseMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, GLKMathDegreesToRadians( (_rotation)*_EarthRotation+180), 0.0, -1.0, 0.0);
    //
    ////// need to apply korean coordinate -> 35 degree
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, 35, 0.0, 0.0, 1.0f);
    //
    
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, GLKMathDegreesToRadians(15), 0.0, 0.0, 1.0);
    BaseMatrix = GLKMatrix4Translate(BaseMatrix, 0.0, 0.0, -sqrtf(_earthR));
    
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, GLKMathDegreesToRadians((_rotation)*_EarthRotation+180), 0.0, -1.0, 0.0);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, _earthViewR, 1000.0f);
    
    projectionMatrix = GLKMatrix4Multiply(projectionMatrix , BaseMatrix);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    [self buildUniverse];
}
-(void)PlutoView{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 BaseMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    float PlutoDegree = ((_rotation)*_PlutoRotation/7+90);
    float EarthDegree = ((_rotation)*_EarthRotation+180);
    float PlutoRadian = GLKMathDegreesToRadians(PlutoDegree);
    float EarthRadian = GLKMathDegreesToRadians(EarthDegree);
    // pluto must allways look at earth center...? how???
    float R = sqrtf((_plutoX*cosf(PlutoRadian)*cosf(PlutoRadian))+_plutoY*sinf(PlutoRadian)*sinf(PlutoRadian));
    float r = sqrtf(_earthR*cosf(EarthRadian)*cosf(EarthRadian)+_earthR*sinf(EarthRadian)*sinf(EarthRadian));
    float x = R*cosf(PlutoRadian)-r*cosf(EarthRadian);
    float y = R*sinf(PlutoRadian)-r*sinf(EarthRadian);
    float z = sqrtf(x*x+y*y);
    float Theta =GLKMathRadiansToDegrees(asinf(y/z));
   // NSLog(@"x : %f, y : %f ,sin(P):%f  cos(P):%f Theta: %f",x, y,PlutoDegree, PlutoRadian, Theta);
    if(shift && (Theta <= -89.8))   shift = NO;
    if(!shift && (Theta >= 89.8))   shift = YES;
    if (shift)                      Theta = 180.0 - Theta;
    //NSLog(@"x : %f, y : %f ,sin(P):%f  cos(P):%f Theta: %f",x, y,PlutoDegree, PlutoRadian, Theta);
    Theta = GLKMathRadiansToDegrees(PlutoRadian) - Theta;
    
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix,GLKMathDegreesToRadians(Theta), 0.0, 1.0, 0.0);

    BaseMatrix = GLKMatrix4Translate(BaseMatrix, 0.0, 0.0,-R);
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, PlutoRadian, 0.0, -1.0, 0.0);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, _plutoViewR, 1000.0f);
    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, BaseMatrix);
    self.effect.transform.projectionMatrix = projectionMatrix;
    [self buildUniverse];
}
-(void)CameraView{
    float aspect = fabsf(self.view.bounds.size.width/self.view.bounds.size.height);
    GLKMatrix4 BaseMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -600.0f);
    BaseMatrix = GLKMatrix4Rotate(BaseMatrix, GLKMathDegreesToRadians(30), 1.0, 0.0, 0.0);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, _satelliteViewR, 1000.0f);
    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, BaseMatrix);
    self.effect.transform.projectionMatrix = projectionMatrix;
    [self buildUniverse];
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
/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw : %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume : %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume : %f", self.timeSinceLastResume);
    self.paused = !self.paused;
}
 */
@end
