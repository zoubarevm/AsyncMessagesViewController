//
//  Messaging.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 17/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import Foundation

public typealias MessageDataContentType = Int
public let kAMMessageDataContentTypeText: MessageDataContentType = 0
public let kAMMessageDataContentTypeNetworkImage: MessageDataContentType = 1
public let kAMMessageDataContentTypeVideo: MessageDataContentType = 2

@objc public protocol MessageData {
    
    func messageKey() -> String
    
    func contentType() -> MessageDataContentType
    
    func content() -> String
    
    func date() -> Date
    
    func senderID() -> String
    
    func senderDisplayName() -> String
    
    func senderAvatarURL() -> URL?
    
    func localImageName() -> String
    
    func getPlayButton() -> String
    
    func isMediaPending() -> Bool
    
}
