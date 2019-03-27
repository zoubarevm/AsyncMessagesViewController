//
//  MessageCellNode.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 12/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public let kAMMessageCellNodeAvatarImageSize: CGFloat = 34

public let kAMMessageCellNodeTopTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                                  NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
public let kAMMessageCellNodeContentTopTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
public let kAMMessageCellNodeBottomTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]

class MessageCellNode: ASCellNode {
    
    private let isOutgoing: Bool
    private let topTextNode: ASTextNode?
    private let contentTopTextNode: ASTextNode?
    private let bottomTextNode: ASTextNode?
    private let bubbleNode: ASDisplayNode
    private let avatarImageSize: CGFloat
    //private let avatarImageNode: ASNetworkImageNode?
    private let avatarImageNode: ASNetworkImageNode?
    
    init(isOutgoing: Bool, topText: NSAttributedString?, contentTopText: NSAttributedString?, bottomText: NSAttributedString?, senderAvatarURL: URL?, showsSenderAvatar: Bool, localImageName: String, senderAvatarImageSize: CGFloat = kAMMessageCellNodeAvatarImageSize, bubbleNode: ASDisplayNode) {
        self.isOutgoing = isOutgoing
        
        topTextNode = topText != nil ? ASTextNode() : nil
        topTextNode?.isLayerBacked = true
        topTextNode?.attributedText = topText
        topTextNode?.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        topTextNode?.style.alignSelf = .center
        
        
        
        contentTopTextNode = contentTopText != nil ? ASTextNode() : nil
        contentTopTextNode?.isLayerBacked = true
        contentTopTextNode?.attributedText = contentTopText
        
        avatarImageSize = senderAvatarImageSize
        
        
        avatarImageNode = avatarImageSize > 0 ? ASNetworkImageNode() : nil
        avatarImageNode?.style.preferredSize = CGSize(width: avatarImageSize, height: avatarImageSize)
        avatarImageNode?.backgroundColor = UIColor.clear
        avatarImageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        
        if(showsSenderAvatar){
            if(senderAvatarURL != nil){
                avatarImageNode?.url = senderAvatarURL
            }
            else{
                avatarImageNode?.image =  UIImage(named: localImageName);
            }
        }
        
        self.bubbleNode = bubbleNode
        self.bubbleNode.style.flexShrink = 1
        
        bottomTextNode = bottomText != nil ? ASTextNode() : nil
        bottomTextNode?.isLayerBacked = true
        bottomTextNode?.attributedText = bottomText
        
        super.init()
        
        if let node = topTextNode { addSubnode(node) }
        if let node = contentTopTextNode { addSubnode(node) }
        if let node = avatarImageNode { addSubnode(node) }
        addSubnode(bubbleNode)
        if let node = bottomTextNode { addSubnode(node) }
        
        //backgroundColor = .red
        selectionStyle = .none
        //separatorInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0);
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let unfilteredChildren: [ASLayoutElement?] = [
            topTextNode,
            (contentTopTextNode != nil)
                ? ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 22 + avatarImageSize, bottom: 0, right: 0), child: contentTopTextNode!)
                : nil,
            ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 2,
                justifyContent: .start, // Never used
                alignItems: .end,
                children: Array.filterNils(from: isOutgoing ? [bubbleNode, avatarImageNode] : [avatarImageNode, bubbleNode])),
            (bottomTextNode != nil)
                ? ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0), child: bottomTextNode!)
                : nil]
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4),
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 0,
                justifyContent: .start, // Never used
                alignItems: isOutgoing ? .end : .start,
                children: Array.filterNils(from: unfilteredChildren)))
    }
    
}

private extension Array {
    
    // Credits: http://stackoverflow.com/a/28190873/1136669
    static func filterNils(from array: [Element?]) -> [Element] {
        return array.filter { $0 != nil }.map { $0! }
    }
    
}
