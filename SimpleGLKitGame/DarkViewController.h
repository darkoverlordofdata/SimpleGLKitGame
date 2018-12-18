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
#import <GLKit/GLKit.h>
#import "DarkSprite.h"
#import "IDarkGame.h"
#import "SimpleAudioEngine.h"

@interface DarkViewController : GLKViewController

@property (strong, nonatomic) EAGLContext *Context;
@property (strong) GLKBaseEffect *Effect;
@property (strong) DarkSprite *Player;
@property (strong) NSMutableArray *Children;
@property (assign) float TimeSinceLastSpawn;
@property (strong) NSMutableArray *Projectiles;
@property (strong) NSMutableArray *Targets;
@property (assign) int TargetsDestroyed;

// GLKViewController/native method
- (void)glkView:(GLKView *)view drawInRect : (CGRect)rect;
- (void)viewDidLoad;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)update;

// DarkViewController methods are PascalCase
- (void)AddSprite : (DarkSprite *)sprite;
- (void)SetPlayer : (DarkSprite *)sprite;
- (void)OnTap:(UITapGestureRecognizer *)recognizer;
- (void)AddTarget;

@end
