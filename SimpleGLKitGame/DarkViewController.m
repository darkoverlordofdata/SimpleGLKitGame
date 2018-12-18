/*******************************************************************
** This code is part of the Dark Framework.
**
MIT License

Copyright (c) 2018 Dark Overlord of Data

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************/
#import "DarkViewController.h"

/**
 * DarkViewController
 *
 * traffic cop for game events 
 * redirects to user game object
 */
@implementation DarkViewController

/**
 * DarkViewController::viewDidLoad
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.Context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.Context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.Context = self.Context;
    [EAGLContext setCurrentContext:self.Context];
    
    self.Effect = [[GLKBaseEffect alloc] init];
    
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 500, 0, 500, -1024, 1024);
	self.Effect.transform.projectionMatrix = projectionMatrix;
	glViewport(0, 0, 500, 500);

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action : @selector(OnTap : )];
	[self.view addGestureRecognizer : tapRecognizer];

	//[self.game onLoad];
	//======================================================

    self.Player = [[DarkSprite alloc] initWithFile:@"Player.png" effect:self.Effect];    
    self.Player.Position = GLKVector2Make(self.Player.ContentSize.width/2, 160);
    
    self.Children = [NSMutableArray array];
    [self.Children addObject:self.Player];    
    
    self.Projectiles = [NSMutableArray array];
    self.Targets = [NSMutableArray array];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pew-pew.wav"];

}

/**
 * DarkViewController::shouldAutorotateToInterfaceOrientation
 *
 *
 * @param interfaceOrientation enum
 * @returns true or false
 *
 */
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

/**
 * DarkViewController::glkView
 *
 *
 * @param view current view
 * @param rect current region of view
= *
 */
-(void)glkView:(GLKView *)view drawInRect : (CGRect)rect
{
	glClearColor(1, 1, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);

	for (DarkSprite *sprite in self.Children) {
		[sprite Render];
	}
}

/**
 * DarkViewController::update
 *
 *	Runs every clock tick to update all game components
 */
-(void)update
{
	NSMutableArray *projectilesToDelete = [NSMutableArray array];
	for (DarkSprite *projectile in self.Projectiles) {

		NSMutableArray *targetsToDelete = [NSMutableArray array];
		for (DarkSprite *target in self.Targets) {
			if (CGRectIntersectsRect(projectile.BoundingBox, target.BoundingBox)) {
				[targetsToDelete addObject : target];
			}
		}

		for (DarkSprite *target in targetsToDelete) {
			[self.Targets removeObject : target];
			[self.Children removeObject : target];
			self.TargetsDestroyed++;
		}

		if (targetsToDelete.count > 0) {
			[projectilesToDelete addObject : projectile];
		}
	}

	for (DarkSprite *projectile in projectilesToDelete) {
		[self.Projectiles removeObject : projectile];
		[self.Children removeObject : projectile];
	}

	self.TimeSinceLastSpawn += self.timeSinceLastUpdate;
	if (self.TimeSinceLastSpawn > 1.0) {
		self.TimeSinceLastSpawn = 0;
		[self AddTarget];
	}

	for (DarkSprite *sprite in self.Children) {
		[sprite Update : self.timeSinceLastUpdate];
	}
}


/**
 * DarkViewController::addSprite
 *
 *
 * @param sprite to add to engine
= *
 */
- (void)AddSprite:(DarkSprite *)sprite 
{
	[self.Children addObject : sprite];
}

/**
 * DarkViewController::setPlayer
 *
 *
 * @param sprite to set as player
= *
 */
- (void)SetPlayer:(DarkSprite *)sprite
{
	//self.Player = sprite;
}

/**
 * DarkViewController::OnTap
 *
 *
 * @param recognizer for gesture
= *
 */
- (void)OnTap:(UITapGestureRecognizer *)recognizer 
{      
    // 1
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = CGPointMake(touchLocation.x, 320 - touchLocation.y);
	//======================================================

    // 2
    GLKVector2 target = GLKVector2Make(touchLocation.x, touchLocation.y);
    GLKVector2 offset = GLKVector2Subtract(target, self.Player.Position);

	//[self.game OnTap target offet]];
    
    // 3
    GLKVector2 normalizedOffset = GLKVector2Normalize(offset);
    
    // 4
    static float POINTS_PER_SECOND = 480;  
    GLKVector2 MoveVelocity = GLKVector2MultiplyScalar(normalizedOffset, POINTS_PER_SECOND);
        
    // 5
    DarkSprite * sprite = [[DarkSprite alloc] initWithFile:@"Projectile.png" effect:self.Effect];
    sprite.position = self.Player.Position;
    sprite.MoveVelocity = MoveVelocity;
    [self.Children addObject:sprite];
 
    [self.Projectiles addObject:sprite];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew.wav"];
    
}

/**
 * DarkViewController::AddTarget
 *
 */
- (void)AddTarget 
{
    DarkSprite *target = [[DarkSprite alloc] initWithFile:@"Target.png" effect:self.Effect];
    [self.Children addObject:target];
       
    int minY = target.ContentSize.height/2;
    int maxY = 320 - target.ContentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = GLKVector2Make(480 + (target.ContentSize.width/2), actualY);    

    int minVelocity = 480.0/4.0;
    int maxVelocity = 480.0/2.0;
    int rangeVelocity = maxVelocity - minVelocity;
    int actualVelocity = (arc4random() % rangeVelocity) + minVelocity;
    
    target.MoveVelocity = GLKVector2Make(-actualVelocity, 0);
    
    [self.Targets addObject:target];
}

@end

