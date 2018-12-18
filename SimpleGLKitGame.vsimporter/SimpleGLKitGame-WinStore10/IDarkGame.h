#pragma once
#import "DarkViewController.h"

@interface IDarkGame

// native methods
- (id)init;

// DarkSprite methods are PascalCase
- (void)LoadContent;
- (void)Update : (float)deltaTime;
- (void)Draw : (float)deltaTime;
- (void)Dispose;

@end