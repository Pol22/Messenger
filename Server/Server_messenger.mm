//
//  Server_messenger.m
//  Messenger
//
//  Created by Admin on 25.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Server_messenger.h"

#include "messenger.h"
#include <future>
#include <map>
#include <deque>

using namespace messenger;

class Callback : public ILoginCallback, public IRequestUsersCallback
{
public:
    void OnOperationResult(messenger::operation_result::Type result) override
    {
        switch(result)
        {
            case messenger::operation_result::Ok: m_error = false;
            case messenger::operation_result::AuthError: m_error = true;
            case messenger::operation_result::InternalError: m_error = true;
            case messenger::operation_result::NetworkError: m_error = true;
        }
    }
    
    void OnOperationResult(messenger::operation_result::Type result, const messenger::UserList& users) override
    {
        if(result == messenger::operation_result::Ok) {
            m_error = false;
        } else {
            m_error = true;
        }
        m_userList = users;
    }
    
    bool m_error;
    UserList m_userList;
};

class Observer : public IMessagesObserver
{
public:
    void OnMessageStatusChanged(const messenger::MessageId& msgId, messenger::message_status::Type status) override
    {
        statusOfNewMessages[msgId] = status;
    }
    
    void OnMessageReceived(const messenger::UserId& senderId, const messenger::Message& msg) override
    {
        // notification
        m_receivedMsg.clear();
        m_receivedMsg.append(reinterpret_cast<const char*>(&msg.content.data[0]), msg.content.data.size());
        newMessage.push_back(senderId);
        newMessage.push_back(m_receivedMsg);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
        
        // for chat
        messagesForUsers[senderId].push_back(msg.identifier);
        allMessages[msg.identifier] = msg;
        whoseMessages[msg.identifier] = false;
    }
    // for notification
    std::deque<std::string> newMessage;
    std::string m_receivedMsg;
    // userId - [messageId]
    std::map<std::string, std::vector<std::string>> messagesForUsers;
    // messageId - Message
    std::map<std::string, messenger::Message> allMessages;
    std::map<std::string, BOOL> whoseMessages;
    // statuses
    std::map<std::string, message_status::Type> statusOfNewMessages;
};

@interface iMessenger () {
    std::shared_ptr<IMessenger> _imessenger;
    Callback _callback;
    Observer _observer;
}

@end

@implementation iMessenger
// init
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        // TODO: set callbacks
    }
    return self;
}
// connect
- (BOOL)connect: (NSString*) login and: (NSString*) password {
    MessengerSettings settings = MessengerSettings();
    settings.serverUrl = std::string("127.0.0.1");
    _imessenger = GetMessengerInstance(settings);
    SecurityPolicy securitypolicy = SecurityPolicy();
    _imessenger->Login([login UTF8String], [password UTF8String], securitypolicy, &_callback);
    while(_callback.m_error == true);
    _imessenger->RegisterObserver(&_observer);
    return !_callback.m_error;
}
// user list
- (NSMutableArray*)getActiveUsers {
    _imessenger->RequestActiveUsers(&_callback);
    while(_callback.m_error == true)
        ;
    NSMutableArray* ret = [NSMutableArray array];
    for(int i = 0;i < _callback.m_userList.size(); i++)
    {
        [ret addObject:[NSString stringWithUTF8String: _callback.m_userList[i].identifier.c_str()]];
    }
    return ret;
}
// notification
- (NSMutableArray*)getNewMessage {
    NSMutableArray* ret = [NSMutableArray array];
    [ret addObject:[NSString stringWithUTF8String: _observer.newMessage[0].c_str()]];
    _observer.newMessage.pop_front();
    [ret addObject:[NSString stringWithUTF8String: _observer.newMessage[0].c_str()]];
    _observer.newMessage.pop_front();
    return ret;
}
// sending
- (void)SendMessage: (NSString*) user with_message: (NSString*) message {
    MessageContent msg;
    msg.type = messenger::message_content_type::Text;
    std::string msg_str([message UTF8String]);
    std::copy(msg_str.begin(), msg_str.end(), std::back_inserter(msg.data));
    Message sended_message = _imessenger->SendMessage([user UTF8String], msg);
    _observer.allMessages[sended_message.identifier] = sended_message;
    _observer.messagesForUsers[[user UTF8String]].push_back(sended_message.identifier);
    _observer.whoseMessages[sended_message.identifier] = true;
}

- (NSMutableArray*)getAllMessagesIds: (NSString*) user {
    NSMutableArray* ret = [NSMutableArray array];
    size_t size = _observer.messagesForUsers[[user UTF8String]].size();
    std::vector<std::string> *vector_messages = &_observer.messagesForUsers[std::string([user UTF8String])];
    for(int i = 0; i < size; i++)
    {
        _imessenger->SendMessageSeen([user UTF8String], (*vector_messages)[i]);
        [ret addObject:[NSString stringWithUTF8String: (*vector_messages)[i].c_str()]];
    }
    return ret;
}

- (NSString*)getDataForMessageId: (NSString*) messageId {
    std::string messageData;
    messageData.append(reinterpret_cast<const char*>(&_observer.allMessages[[messageId UTF8String]].content.data[0]), _observer.allMessages[[messageId UTF8String]].content.data.size());
    return [NSString stringWithUTF8String: messageData.c_str()];
}

- (NSDate*)getDateForMessageId: (NSString*) messageId {
    return [NSDate dateWithTimeIntervalSince1970:_observer.allMessages[[messageId UTF8String]].time];
}

- (NSString*)getStatusForMessageId: (NSString*) messageId {
    switch(_observer.statusOfNewMessages[[messageId UTF8String]])
    {
        case message_status::Delivered : return @"Delivered";
        case message_status::FailedToSend : return @"FailedToSend";
        case message_status::Seen : return @"Seen";
        case message_status::Sending : return @"Sending";
        case message_status::Sent : return @"Sent";
    }
}

- (BOOL)getWhoseForMessageId: (NSString*) messageId {
    return _observer.whoseMessages[[messageId UTF8String]];
}

- (void)dealloc {
    _imessenger->UnregisterObserver(&_observer);
    _imessenger->Disconnect();
}

@end
