//
//  ABRestoreCookieRequest.h
//  Airbug
//
//  Created by Richard Shin on 6/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABRequest.h"

@interface ABRestoreCookieRequest : ABRequest

@property (strong, nonatomic) NSString *cookieName;

@end
