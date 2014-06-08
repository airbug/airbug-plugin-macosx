//
//  ABRestoreCookieRequest.h
//  Airbug
//
//  Created by Richard Shin on 6/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABRestoreCookieRequest : NSObject

@property (strong, nonatomic) NSString *cookieName;
@property (strong, nonatomic) NSString *messageID;

@end
