//
//  MessageTextBubbleNode.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 13/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public let kAMMessageTextBubbleNodeIncomingTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
public let kAMMessageTextBubbleNodeOutgoingTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
public typealias TextAttributes = [NSAttributedString.Key: AnyObject];

public class MessageTextBubbleNodeFactory: MessageBubbleNodeFactory {

    private let incomingAttr: TextAttributes;
    private let outgoingAttr: TextAttributes;

    public init(incomingTextAttributes: TextAttributes = kAMMessageTextBubbleNodeIncomingTextAttributes, outgoingTextAttributes: TextAttributes = kAMMessageTextBubbleNodeOutgoingTextAttributes) {
        incomingAttr = incomingTextAttributes;
        outgoingAttr = outgoingTextAttributes;
    }

    public func build(message: MessageData, isOutgoing: Bool, bubbleImage: UIImage) -> ASDisplayNode {
        let attributes = isOutgoing
            ? outgoingAttr
            : incomingAttr
        let text = NSAttributedString(string: message.content(), attributes: attributes)
        return MessageTextBubbleNode(text: text, isOutgoing: isOutgoing, bubbleImage: bubbleImage)
    }

}

private class MessageTextNode: ASTextNode {

    override init() {
        super.init()
        placeholderColor = UIColor.clear
        isLayerBacked = true
    }

    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }

}

open class MessageTextBubbleNode: ASDisplayNode {

    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let textNode: ASTextNode

    public init(text: NSAttributedString, isOutgoing: Bool, bubbleImage: UIImage) {
        self.isOutgoing = isOutgoing

        bubbleImageNode = ASImageNode()
        bubbleImageNode.image = bubbleImage

        textNode = MessageTextNode()
        textNode.attributedText = text

        super.init()

        addSubnode(bubbleImageNode)
        addSubnode(textNode)
    }

    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsets(
                    top: 12,
                    left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),
                    bottom: 12,
                    right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),
                child: textNode),
            background: bubbleImageNode)
    }

}
