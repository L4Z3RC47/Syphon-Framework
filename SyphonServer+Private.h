//
//  SyphonServer+Private.h
//  Syphon
//
//  Created by vade on 11/19/17.
//

#import "SyphonServer.h"

@interface SyphonServer (Private)
- (id) initWithName:(NSString*)serverName options:(NSDictionary *)options;
- (void) shutDownServer;
@end
