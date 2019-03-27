//
//  MessageBubbleImageProvider.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 8/5/14, inspired by JSQMessagesBubbleImageFactory
//  Copyright (c) 2014 Huy Nguyen. All rights reserved.
//

import UIKit

private struct MessageProperties: Hashable {
    let isOutgoing: Bool
    let hasTail: Bool
    let isVideoMessage: Bool
    let isMediaPending: Bool
    
    var hashValue: Int {
        return (31 &* isOutgoing.hashValue) &+ (43 &* isMediaPending.hashValue) &+ (58 &* hasTail.hashValue) &+ isVideoMessage.hashValue
    }
}

private func ==(lhs: MessageProperties, rhs: MessageProperties) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public let kDefaultIncomingColor = UIColor(red: 239 / 255, green: 237 / 255, blue: 237 / 255, alpha: 1)
public let kDefaultOutgoingColor = UIColor(red: 17 / 255, green: 107 / 255, blue: 254 / 255, alpha: 1)
public let kDefaultVideoColor =  UIColor.black;

private let kBundleName = "AsyncMessagesViewController.bundle"
private let kTableName = "AsyncMessagesViewController"

public class MessageBubbleImageProvider {
    
    private let outgoingColor: UIColor
    private let incomingColor: UIColor
    private let videoImageBackgroundColor: UIColor
    
    
    private var imageCache = [MessageProperties: UIImage]()
    
    static func getBubbleImage(_ imageName: String) -> UIImage{
        let podBundle = Bundle(for: MessageBubbleImageProvider.self)
        
        if let bundleURL = podBundle.resourceURL?.appendingPathComponent("AsyncMessagesViewController.bundle"){
            if let bundle = Bundle.init(url: bundleURL){
                guard let imagePath = bundle.path(forResource: imageName, ofType: "png") else {
                    return UIImage()
                }
        
                guard let image = UIImage(contentsOfFile: imagePath) else {
                    return UIImage();
                }
                
                return image;
        
            }
            else{
                print("bundle could not be loaded")
            }
        }
        
        print("bundle could not be found");
        
        return UIImage()
        
    }
    
    public init(incomingColor: UIColor = kDefaultIncomingColor, outgoingColor: UIColor = kDefaultOutgoingColor, videoColor: UIColor = kDefaultVideoColor) {
        self.incomingColor = incomingColor
        self.outgoingColor = outgoingColor
        self.videoImageBackgroundColor = videoColor
    }
    
    func bubbleImage(isOutgoing: Bool, hasTail: Bool, isVideoMessage: Bool = false, isMediaPending: Bool = false) -> UIImage {
        let properties = MessageProperties(isOutgoing: isOutgoing, hasTail: hasTail, isVideoMessage: isVideoMessage, isMediaPending: isMediaPending)
        return bubbleImage(properties: properties)
    }
    
    private func bubbleImage(properties: MessageProperties) -> UIImage {
        if let image = imageCache[properties] {
            return image
        }
        
        let image = buildBubbleImage(properties: properties)
        imageCache[properties] = image
        return image
    }
    
    private func buildBubbleImage(properties: MessageProperties) -> UIImage {
        let imageName = "bubble" + (properties.isOutgoing ? "_outgoing" : "_incoming") + (properties.hasTail ? "" : "_tailless")

        
          let bubble =  MessageBubbleImageProvider.getBubbleImage(imageName);
        
        do {
            var color: UIColor!
            
            if(properties.isMediaPending){
                color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            }
            else if(properties.isVideoMessage){
                color = videoImageBackgroundColor
            }
            else{
                color = properties.isOutgoing ? outgoingColor : incomingColor
            }
            var normalBubble = try bubble.imageMaskedWith(color: color)
            
            
            // make image stretchable from center point
            let center = CGPoint(x: bubble.size.width / 2.0, y: bubble.size.height / 2.0)
            let capInsets = UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x);
            
            normalBubble = MessageBubbleImageProvider.stretchableImage(source: normalBubble, capInsets: capInsets)
            return normalBubble
        } catch {
            return bubble
        }
    }
    
    private class func stretchableImage(source: UIImage, capInsets: UIEdgeInsets) -> UIImage {
        return source.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
    
}

