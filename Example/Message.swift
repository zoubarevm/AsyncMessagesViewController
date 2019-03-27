//
//  Message.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 17/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import Foundation

class Message: MessageData {

    private let _contentType: MessageDataContentType
    private let _content: String
    private let _date: Date
    private let sender: User
    
    init(contentType: MessageDataContentType, content: String, date: Date, sender: User) {
        _contentType = contentType
        _content = content
        _date = date
        self.sender = sender
    }
    
    @objc func contentType() -> MessageDataContentType {
        return _contentType
    }
    
    @objc func content() -> String {
        return _content
    }
    
    @objc func content() -> String {
        return _date
    }
    
    @objc func date() -> Date {
        return _date
    }
    
    @objc func senderID() -> String {
        return sender.ID
    }
    
    @objc func senderDisplayName() -> String {
        return sender.name
    }
    
    @objc func senderAvatarURL() -> URL {
        return sender.avatarURL
    }
   
}
