//
//  MessageTextBubbleNode.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 13/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public let defaultVideoTextBubbleNodeOutgoingTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]


public class MessageVideoBubbleNodeFactory: MessageBubbleNodeFactory {

    //private let videoTextAttr: TextAttributes;
    
    public init(textAttributes: TextAttributes = defaultVideoTextBubbleNodeOutgoingTextAttributes){
        //videoTextAttr = textAttributes;
    }
    
    public func build(message: MessageData, isOutgoing: Bool, bubbleImage: UIImage) -> ASDisplayNode {
        //let text = NSAttributedString(string: message.content(), attributes: videoTextAttr)
        
        return MessageVideoImageBubbleNode(videoURL: URL(string: message.content()), playButtonName: message.getPlayButton(), isOutgoing: isOutgoing, bubbleImage: bubbleImage)
    }
    
}

private class MessageNode: ASDisplayNode {
    private let size = CGSize(width: 150, height: 100)
    public let playImage: ASImageNode!
    
    public override init(){
        playImage = ASImageNode();
        
        super.init()
    }
    public init(playButton: UIImage?) {
        playImage = ASImageNode();
        playImage.image = playButton
        playImage.style.preferredSize = CGSize(width: 20, height: 20)
        
        super.init()
        
        //isLayerBacked = true
        style.preferredSize = self.size
        
        addSubnode(playImage)
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: playImage)
        return centerSpec
    }
}

open class MessageVideoImageBubbleNode: ASDisplayNode {
    
    private let isOutgoing: Bool
//    private let bubbleImageNode: ASImageNode
    private let bubbleImage: UIImage
    private let buttonNode: ASDisplayNode
    private let thumbnailNode: ASImageNode
    private let size: CGSize
    private let videoURL: URL?
    
    public init(videoURL: URL?, playButtonName: String, isOutgoing: Bool, bubbleImage: UIImage, size: CGSize = CGSize(width: 150, height: 150)) {
        self.isOutgoing = isOutgoing
        self.size = size
        self.bubbleImage = bubbleImage
        self.videoURL = videoURL;
        

        
        //bubbleImageNode = ASImageNode()
        //bubbleImageNode.forcedSize = size;
        //bubbleImageNode.image = bubbleImage
        
        buttonNode = MessageNode(playButton: UIImage(named: playButtonName))
        
//        buttonNode.playImage.image = UIImage(named: playButtonName)
        //textNode.attributedText = text
        
        thumbnailNode = ASImageNode()
        thumbnailNode.backgroundColor = UIColor.gray;
        


        
        super.init()
        
        //addSubnode(bubbleImageNode)
        addSubnode(thumbnailNode)
        addSubnode(buttonNode)
    }
    
    override open func didLoad() {
        super.didLoad()
        let mask = UIImageView(image: bubbleImage)
        mask.frame.size = calculatedSize
        view.layer.mask = mask.layer
        view.backgroundColor = UIColor.gray
        
        if(self.videoURL != nil){
            weak var tN = thumbnailNode;
            MediaUtils.getThumbnailFromVideo(urlString: self.videoURL!.absoluteString, { (image) in
                DispatchQueue.main.async {
                    tN?.image = image;
                }
            })
        }
    }

    

    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        let buttonNodeLayout = ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: 12,
                left:12 + (isOutgoing ? 0 : textNodeVerticalOffset),
                bottom:12,
                right:12 + (isOutgoing ? textNodeVerticalOffset : 0)),
            child: buttonNode)
        
        return ASBackgroundLayoutSpec(
            child: buttonNodeLayout,
            background: thumbnailNode)

//        return ASBackgroundLayoutSpec(
//            child: ASInsetLayoutSpec(
//                insets: UIEdgeInsetsMake(
//                    12,
//                    12 + (isOutgoing ? 0 : textNodeVerticalOffset),
//                    12,
//                    12 + (isOutgoing ? textNodeVerticalOffset : 0)),
//                child: buttonNode),
//            background: bubbleImageNode)
//        return ASBackgroundLayoutSpec(child: textNode, background: bubbleImageNode)
    }
    
}
