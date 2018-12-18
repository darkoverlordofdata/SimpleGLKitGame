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
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct DarkTexturedVertex
{
	CGPoint geometryVertex;
	CGPoint textureVertex;

} DarkTexturedVertex;

typedef struct DarkTexturedQuad
{
	DarkTexturedVertex bl;
	DarkTexturedVertex br;
	DarkTexturedVertex tl;
	DarkTexturedVertex tr;

} DarkTexturedQuad;


@interface DarkSprite : NSObject

@property (assign) GLKVector2 Position;
@property (assign) CGSize ContentSize;
@property (assign) GLKVector2 MoveVelocity;
@property (strong) GLKBaseEffect *Effect;
@property (assign) DarkTexturedQuad Quad;
@property (strong) GLKTextureInfo *TextureInfo;

// native methods
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;

// DarkSprite methods are PascalCase
- (void)Render;
- (void)Update:(float)dt;
- (CGRect)BoundingBox;
- (GLKMatrix4)ModelMatrix;

@end
