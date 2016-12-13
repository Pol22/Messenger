//
//  Server_messenger.h
//  Messenger
//
//  Created by Admin on 25.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iMessenger : NSObject

- (instancetype)init;
- (BOOL)connect: (NSString*) login and: (NSString*) password;
- (NSMutableArray*)getActiveUsers;
- (NSMutableArray*)getNewMessage;
- (void)SendMessage: (NSString*) user with_message: (NSString*) message;
- (NSMutableArray*)getAllMessagesIds: (NSString*) user;
- (NSString*)getDataForMessageId: (NSString*) messageId;
- (NSDate*)getDateForMessageId: (NSString*) messageId;
- (NSString*)getStatusForMessageId: (NSString*) messageId;
- (BOOL)getWhoseForMessageId: (NSString*) messageId;

@end
