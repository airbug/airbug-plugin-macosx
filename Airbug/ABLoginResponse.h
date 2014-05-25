//
//  ABLoginResponse.h
//  Airbug
//
//  Created by Richard Shin on 5/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABLoginResponse : NSObject

@property (nonatomic) BOOL success;
@property (strong, nonatomic) NSString *meldDocument;
@property (strong, nonatomic) NSString *errorMessage;

@end
