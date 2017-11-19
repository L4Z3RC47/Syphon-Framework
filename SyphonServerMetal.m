//
//  SyphonServerMetal.m
//  Syphon
//
//  Created by vade on 11/19/17.
//

#import <Metal/Metal.h>
#import "SyphonServerMetal.h"
#import "SyphonServer+Private.h"
#import "SyphonPrivate.h"
#import "SyphonServerConnectionManager.h"

@interface SyphonServerMetal ()
{
    IOSurfaceRef _surfaceRef;
}
@property (readwrite, strong) id<MTLDevice> device;
@property (readwrite, strong) id<MTLCommandQueue> commandQueue;
@property (readwrite, strong) id<MTLTexture> surfaceTexture;

@end
@implementation SyphonServerMetal

- (id)initWithName:(NSString*)serverName device:(id<MTLDevice>)device options:(NSDictionary *)options
{
    self = [super initWithName:serverName options:options];
    if(self)
    {
        if (device == nil)
        {
            [self release];
            return nil;
        }
        
        self.device = device;
        self.commandQueue = [self.device newCommandQueue];
        
    }
    
    return self;
}

- (void)stop
{
    
}

- (void) destroyIOSurface
{
    if (_surfaceRef != NULL)
    {
        CFRelease(_surfaceRef);
        _surfaceRef = NULL;
    }
    
    [_surfaceTexture release];
    _surfaceTexture = nil;

}

- (void) setupIOSurfaceForSize:(NSSize)size
{
    
    NSDictionary* surfaceAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], (NSString*)kIOSurfaceIsGlobal,
                                       [NSNumber numberWithUnsignedInteger:(NSUInteger)size.width], (NSString*)kIOSurfaceWidth,
                                       [NSNumber numberWithUnsignedInteger:(NSUInteger)size.height], (NSString*)kIOSurfaceHeight,
                                       [NSNumber numberWithUnsignedInteger:4U], (NSString*)kIOSurfaceBytesPerElement, nil];
    
    _surfaceRef =  IOSurfaceCreate((CFDictionaryRef) surfaceAttributes);
    [surfaceAttributes release];

    MTLTextureDescriptor* surfaceTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRG422 width:size.width height:size.height mipmapped:NO];
    
    self.surfaceTexture =[ self.device newTextureWithDescriptor:surfaceTextureDescriptor iosurface:_surfaceRef plane:0];
}


- (void)publishFrameTexture:(id<MTLTexture>)texture imageRegion:(NSRect)region flipped:(BOOL)isFlipped
{
    // We need a new command buffer
    id<MTLCommandBuffer> frameCommandBuffer = [self.commandQueue commandBuffer];
    
    id<MTLBlitCommandEncoder> blitCommandEncoder = [frameCommandBuffer blitCommandEncoder];
    
    [blitCommandEncoder copyFromTexture:texture
                            sourceSlice:0
                            sourceLevel:0
                           sourceOrigin:MTLOriginMake(region.origin.x, region.origin.y, 0)
                             sourceSize:MTLSizeMake(region.size.width, region.size.height, 1)
                              toTexture:self.surfaceTexture
                       destinationSlice:0
                       destinationLevel:0
                      destinationOrigin:MTLOriginMake(0, 0, 0)];
    
    [blitCommandEncoder endEncoding];
    
    [frameCommandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull commandBuffer) {
       
        // Mark ourselves with new frame available
        [(SyphonServerConnectionManager *)_connectionManager setSurfaceID:IOSurfaceGetID(_surfaceRef)];

    }];
    
    [frameCommandBuffer commit];
}

@end
