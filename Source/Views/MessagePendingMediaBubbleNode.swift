//
//  MessageTextBubbleNode.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 13/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import UIKit
import AsyncDisplayKit



public class MessagePendingMediaBubbleNodeFactory: MessageBubbleNodeFactory {
    
    
    public init(){
    }
    
    public func build(message: MessageData, isOutgoing: Bool, bubbleImage: UIImage) -> ASDisplayNode {
        
        return MessagePendingMediaBubbleNode(isOutgoing: isOutgoing, bubbleImage: bubbleImage)
    }
    
}

private class MessageNode: ASDisplayNode {
    private let size = CGSize(width: 150, height: 100)
    public let activityNode: ASDisplayNode!
    
    public override init(){
        activityNode = ASDisplayNode{
            () -> UIView in
            //let activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30  ));
            let activityView = UIView()
            //activityView.backgroundColor = UIColor.red;
            activityView.isOpaque = false;
            
            let loader = UIActivityIndicatorView();
            loader.color = UIColor.black;
            
            loader.translatesAutoresizingMaskIntoConstraints = false
            

            
            activityView.addSubview(loader)
            let horizontalConstraint = NSLayoutConstraint(item: loader, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: activityView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            activityView.addConstraint(horizontalConstraint)

            let verticalConstraint = NSLayoutConstraint(item: loader, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: activityView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            activityView.addConstraint(verticalConstraint)
            loader.startAnimating()
            
            return activityView
        };

        
        activityNode.style.preferredSize = CGSize(width: 60, height: 60)
        //activityNode.backgroundColor = UIColor.red;
        
        super.init()
        
        //isLayerBacked = true
        style.preferredSize = self.size
        
        addSubnode(activityNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: activityNode)
        return centerSpec
    }
}

open class MessagePendingMediaBubbleNode: ASDisplayNode {
    
    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let buttonNode: ASDisplayNode
    
    public init(isOutgoing: Bool, bubbleImage: UIImage ) {
        self.isOutgoing = isOutgoing
        
        bubbleImageNode = ASImageNode()
        //bubbleImageNode.forcedSize = size;
        bubbleImageNode.image = bubbleImage
        
        buttonNode = MessageNode()
        
        super.init()
        
        addSubnode(bubbleImageNode)
        addSubnode(buttonNode)
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
                child: buttonNode),
            background: bubbleImageNode)
        //        return ASBackgroundLayoutSpec(child: textNode, background: bubbleImageNode)
    }
    
}
