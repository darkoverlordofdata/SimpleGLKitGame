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
#import "DarkSprite.h"

/**
 * DarkSprite
 */
@implementation DarkSprite

/**
 * DarkSprite::initWithFile
 *
 *
 * @param fileName image file to load
 * @param effect shader used to display the image
 * @returns self as id
 *
 */
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect 
{
    if ((self = [super init])) {
        self.Effect = effect;
        
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft, 
                                  nil];
        
        NSError * error;    
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        self.TextureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (self.TextureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        self.ContentSize = CGSizeMake(self.TextureInfo.width, self.TextureInfo.height);
                
        DarkTexturedQuad newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(self.TextureInfo.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, self.TextureInfo.height);
        newQuad.tr.geometryVertex = CGPointMake(self.TextureInfo.width, self.TextureInfo.height);

        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.Quad = newQuad;

    }
    return self;
}

/**
 * DarkSprite::modelMatrix
 *
 *
 * @returns current location translation
 *
 */
- (GLKMatrix4) ModelMatrix 
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;    
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.Position.x, self.Position.y, 0);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -self.ContentSize.width/2, -self.ContentSize.height/2, 0);
    return modelMatrix;
}

/**
 * DarkSprite::render
 *
 */
- (void)Render 
{
    self.Effect.texture2d0.name = self.TextureInfo.name;
    self.Effect.texture2d0.enabled = YES;
    self.Effect.transform.ModelviewMatrix = self.ModelMatrix;
    
    [self.Effect prepareToDraw];
       
    long offset = (long)&_Quad;
       
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(DarkTexturedVertex), (void *) (offset + offsetof(DarkTexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(DarkTexturedVertex), (void *) (offset + offsetof(DarkTexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

/**
 * DarkSprite::update
 *
 *
 * @param dt time delta in ms
 *
 */
- (void)Update:(float)dt 
{
    GLKVector2 curMove = GLKVector2MultiplyScalar(self.MoveVelocity, dt);
    self.Position = GLKVector2Add(self.Position, curMove);
}

/**
 * DarkSprite::boundingBox
 *
 *
 * @returns this sprite's bounding box rectangle
 *
 */
- (CGRect)BoundingBox 
{
    CGRect rect = CGRectMake(self.Position.x, self.Position.y, self.ContentSize.width, self.ContentSize.height);
    return rect;
}

@end
