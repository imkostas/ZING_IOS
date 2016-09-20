//
//  Pair.h
//  Zing
//
//  Created by Kostas on 7/30/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pair : NSObject

@property (nonatomic, strong) NSString *udid_1; // device token 1
@property (nonatomic, strong) NSString *udid_2; // device token 2
@property (nonatomic, strong) NSString *session_id; // session id (= wild card)

@end
