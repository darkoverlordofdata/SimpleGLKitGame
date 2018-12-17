//
//  SGGViewController.m
//  SimpleGLKitGame
//
//  Created by Ray Wenderlich on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGGViewController.h"
#import "SGGSprite.h"
#import "SimpleAudioEngine.h"

@interface SGGViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * effect;
@property (strong) SGGSprite * player;
@property (strong) NSMutableArray * children;
@property (assign) float timeSinceLastSpawn;
@property (strong) NSMutableArray *projectiles;
@property (strong) NSMutableArray *targets;
@property (assign) int targetsDestroyed;
@end

@implementation SGGViewController
@synthesize effect = _effect;
@synthesize context = _context;
@synthesize player = _player;
@synthesize children = _children;
@synthesize timeSinceLastSpawn = _timeSinceLastSpawn;
@synthesize projectiles = _projectiles;
@synthesize targets = _targets;
@synthesize targetsDestroyed = _targetsDestroyed;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    //GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 500, 0, 500, -1024, 1024);
	self.effect.transform.projectionMatrix = projectionMatrix;
	glViewport(0, 0, 500, 500);

    self.player = [[SGGSprite alloc] initWithFile:@"Player.png" effect:self.effect];    
    self.player.position = GLKVector2Make(self.player.contentSize.width/2, 160);
    
    self.children = [NSMutableArray array];
    [self.children addObject:self.player];    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];                                                               
    [self.view addGestureRecognizer:tapRecognizer];

    self.projectiles = [NSMutableArray array];
    self.targets = [NSMutableArray array];
    
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pew-pew.wav"];

}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer { 
        
    // 1
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = CGPointMake(touchLocation.x, 320 - touchLocation.y);
    
    // 2
    GLKVector2 target = GLKVector2Make(touchLocation.x, touchLocation.y);
    GLKVector2 offset = GLKVector2Subtract(target, self.player.position);
    
    // 3
    GLKVector2 normalizedOffset = GLKVector2Normalize(offset);
    
    // 4
    static float POINTS_PER_SECOND = 480;  
    GLKVector2 moveVelocity = GLKVector2MultiplyScalar(normalizedOffset, POINTS_PER_SECOND);
        
    // 5
    SGGSprite * sprite = [[SGGSprite alloc] initWithFile:@"Projectile.png" effect:self.effect];
    sprite.position = self.player.position;
    sprite.moveVelocity = moveVelocity;
    [self.children addObject:sprite];
 
    [self.projectiles addObject:sprite];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew.wav"];
    
}

- (void)addTarget {
    SGGSprite * target = [[SGGSprite alloc] initWithFile:@"Target.png" effect:self.effect];
    [self.children addObject:target];
       
    int minY = target.contentSize.height/2;
    int maxY = 320 - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = GLKVector2Make(480 + (target.contentSize.width/2), actualY);    

    int minVelocity = 480.0/4.0;
    int maxVelocity = 480.0/2.0;
    int rangeVelocity = maxVelocity - minVelocity;
    int actualVelocity = (arc4random() % rangeVelocity) + minVelocity;
    
    target.moveVelocity = GLKVector2Make(-actualVelocity, 0);
    
    [self.targets addObject:target];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (SGGSprite * sprite in self.children) {
        [sprite render];
    }
}

- (void)update {    
    
    NSMutableArray * projectilesToDelete = [NSMutableArray array];
    for (SGGSprite * projectile in self.projectiles) {
        
        NSMutableArray * targetsToDelete = [NSMutableArray array];
        for (SGGSprite * target in self.targets) {            
            if (CGRectIntersectsRect(projectile.boundingBox, target.boundingBox)) {
                [targetsToDelete addObject:target];
            }            
        }
        
        for (SGGSprite * target in targetsToDelete) {
            [self.targets removeObject:target];
            [self.children removeObject:target];
            _targetsDestroyed++;
        }
        
        if (targetsToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
    }

    for (SGGSprite * projectile in projectilesToDelete) {
        [self.projectiles removeObject:projectile];
        [self.children removeObject:projectile];
    }
    
    self.timeSinceLastSpawn += self.timeSinceLastUpdate;
    if (self.timeSinceLastSpawn > 1.0) {
        self.timeSinceLastSpawn = 0;
        [self addTarget];
    }
    
    for (SGGSprite *sprite in self.children) {
        [sprite update:self.timeSinceLastUpdate];
    }
}
 
@end

#ifdef WINOBJC
// Tell the WinObjC runtime how large to render the application
@implementation UIApplication(UIApplicationInitialStartupMode)
+ (void)setStartupDisplayMode:(WOCDisplayMode*)mode {
	mode.autoMagnification = TRUE;
	mode.sizeUIWindowToFit = TRUE;
	mode.fixedWidth = 0;
	mode.fixedHeight = 0;
	mode.magnification = 1.0;
}
@end
#endif
