//
//  MessageNetworkImageBubbleNode.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 27/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import AsyncDisplayKit

public class MessageNetworkImageBubbleNodeFactory: MessageBubbleNodeFactory {
    public init(){}
    
    public func build(message: MessageData, isOutgoing: Bool, bubbleImage: UIImage) -> ASDisplayNode {
        let url = URL(string: message.content())
        return MessageNetworkImageBubbleNode(url: url, bubbleImage: bubbleImage)
    }
    
}

open class MessageNetworkImageBubbleNode: ASNetworkImageNode {
    private let minSize: CGSize
    private let bubbleImage: UIImage
    private var imageURL: URL?
    
    public init(url: URL?, bubbleImage: UIImage, minSize: CGSize = CGSize(width: 210, height: 150)) {
        self.minSize = minSize
        self.bubbleImage = bubbleImage
        super.init(cache: nil, downloader: ASBasicImageDownloader.shared())
        
        //using self.url downloads and sets the image background for the ASNetworkImageNode
        //self.url = url
        
        self.imageURL = url
    }
    
    override open func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        return CGSize(width: min(constrainedSize.width, minSize.width), height: min(constrainedSize.height, minSize.height))
    }
    
    override open func didLoad() {
        super.didLoad()
        let mask = UIImageView(image: bubbleImage)
        mask.frame.size = calculatedSize
        view.layer.mask = mask.layer
        view.backgroundColor = UIColor.gray
        
        if(self.imageURL != nil){
            weak var weakSelf = self;
            MediaUtils.getCachedImage(urlString: self.imageURL!.absoluteString, { (image) in
                DispatchQueue.main.async {
                    weakSelf?.image = image;
                }
            })
        }
        
        
    }
    
}
