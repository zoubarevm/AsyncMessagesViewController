//
//  DefaultAsyncMessagesCollectionViewDataSource.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 17/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import Foundation
import AsyncDisplayKit

open class DefaultAsyncMessagesCollectionViewDataSource: NSObject, AsyncMessagesCollectionViewDataSource {
    
    private let nodeMetadataFactory: MessageCellNodeMetadataFactory
    private let bubbleImageProvider: MessageBubbleImageProvider
    private let timestampFormatter: MessageTimestampFormatter
    private let bubbleNodeFactories: [MessageDataContentType: MessageBubbleNodeFactory]
    private var _currentUserID: String?
    /// Managed messages. They are sorted in ascending order of their date. The order is enforced during insertion.
    private var messages: [MessageData]
    private var nodeMetadatas: [MessageCellNodeMetadata]
    
    public init(currentUserID: String? = nil,
        nodeMetadataFactory: MessageCellNodeMetadataFactory = MessageCellNodeMetadataFactory(),
        bubbleImageProvider: MessageBubbleImageProvider = MessageBubbleImageProvider(),
        timestampFormatter: MessageTimestampFormatter = MessageTimestampFormatter(),
        bubbleNodeFactories: [MessageDataContentType: MessageBubbleNodeFactory] = [
            kAMMessageDataContentTypeText: MessageTextBubbleNodeFactory(),
            kAMMessageDataContentTypeNetworkImage: MessageNetworkImageBubbleNodeFactory(),
            kAMMessageDataContentTypeVideo: MessageVideoBubbleNodeFactory(),
        ]) {
            _currentUserID = currentUserID
            self.nodeMetadataFactory = nodeMetadataFactory
            self.bubbleImageProvider = bubbleImageProvider
            self.timestampFormatter = timestampFormatter
            self.bubbleNodeFactories = bubbleNodeFactories
            messages = []
            nodeMetadatas = []
    }

    //MARK: ASCollectionDataSource methods
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        assert(nodeMetadatas.count == messages.count, "Node metadata is required for each message.")
        return messages.count
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let message = self.collectionNode(collectionNode: collectionNode, messageForItemAtIndexPath: indexPath)
        let metadata = nodeMetadatas[indexPath.item]
        let isOutgoing = metadata.isOutgoing

        let senderAvatarURL: URL? = metadata.showsSenderAvatar ? message.senderAvatarURL() : nil
        let messageDate: NSAttributedString? = metadata.showsDate
            ? timestampFormatter.attributedTimestamp(date: message.date())
            : nil
        let senderDisplayName: NSAttributedString? = metadata.showsSenderName
            ? NSAttributedString(string: message.senderDisplayName(), attributes: kAMMessageCellNodeContentTopTextAttributes)
            : nil
        
        let bubbleImage = bubbleImageProvider.bubbleImage(isOutgoing: isOutgoing, hasTail: metadata.showsTailForBubbleImage, isVideoMessage: metadata.isVideoMessage, isMediaPending: metadata.isPendingMessage)
        assert(bubbleNodeFactories.index(forKey: message.contentType()) != nil, "No bubble node factory for content type: \(message.contentType())")
        
        let factory = metadata.isPendingMessage ? MessagePendingMediaBubbleNodeFactory() : bubbleNodeFactories[message.contentType()]!
        let bubbleNode = factory.build(message: message, isOutgoing: isOutgoing, bubbleImage: bubbleImage)

        let cellNodeBlock:() -> ASCellNode = {
            let cellNode = MessageCellNode(
                isOutgoing: isOutgoing,
                topText: messageDate,
                contentTopText: senderDisplayName,
                bottomText: nil,
                senderAvatarURL: senderAvatarURL,
                showsSenderAvatar: metadata.showsSenderAvatar,
                localImageName: message.localImageName(),
                bubbleNode: bubbleNode)
            return cellNode
        }
        return cellNodeBlock
    }

    public func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionView.bounds.width;
        // Assume horizontal scroll directions
        return ASSizeRangeMake(CGSize(width: width, height: 0), CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }

    //MARK: AsyncMessagesCollectionViewDataSource methods
    public func currentUserID() -> String? {
        return _currentUserID
    }
    
    public func collectionNode(collectionNode: ASCollectionNode, updateCurrentUserID newUserID: String?) {
        if newUserID == _currentUserID {
            return
        }
        
        _currentUserID = newUserID
        
        let outdatedMetadatas = nodeMetadatas
        let updatedMetadatas = nodeMetadataFactory.buildMetadatas(for: messages, currentUserID: _currentUserID)
        nodeMetadatas = updatedMetadatas
        
        let reloadIndicies = Array<MessageCellNodeMetadata>.computeDiff(lhs: outdatedMetadatas, rhs: updatedMetadatas)
        collectionNode.reloadItems(at: IndexPath.createIndexPaths(section: 0, items: reloadIndicies))
    }

    public func collectionNode(collectionNode: ASCollectionNode, messageForItemAtIndexPath indexPath: IndexPath) -> MessageData {
        return messages[indexPath.item]
    }
    
    public func collectionNode(collectionNode: ASCollectionNode, insertMessages newMessages: [MessageData], completion: ((Bool) -> ())?) {
        if newMessages.isEmpty {
            return
        }
        
        var insertedIndices = [Int]()
        // Sort new messages to make sure insertion starts from the begining of the array and previous insertion indicies are always valid.
        let isOrderedBefore: (MessageData, MessageData) -> Bool = {
            $0.date().compare($1.date()) == ComparisonResult.orderedAscending
        }
        for newMessage in newMessages.sorted(by: isOrderedBefore) {
            insertedIndices.append(messages.insert(newElement: newMessage, isOrderedBefore: isOrderedBefore))
        }
        
        var outdatedNodeMetadatas = nodeMetadatas
        let updatedNodeMetadatas = nodeMetadataFactory.buildMetadatas(for: messages, currentUserID: _currentUserID)
        nodeMetadatas = updatedNodeMetadatas

        // Copy metadata of new messages to the outdated metadata array. Thus outdated and updated arrays will have the same size and computing diff between them will be much easier.
        for insertedIndex in insertedIndices {
            outdatedNodeMetadatas.insert(updatedNodeMetadatas[insertedIndex], at: insertedIndex)
        }
        let reloadIndicies = Array<MessageCellNodeMetadata>.computeDiff(lhs: outdatedNodeMetadatas, rhs: updatedNodeMetadatas)
        
        collectionNode.performBatchUpdates(
            {
                collectionNode.insertItems(at: IndexPath.createIndexPaths(section: 0, items: insertedIndices))
                if !reloadIndicies.isEmpty {
                    collectionNode.reloadItems(at: IndexPath.createIndexPaths(section: 0, items: reloadIndicies))
                }
        },
            completion: completion)
    }
  
    public func collectionNode(collectionNode: ASCollectionNode, deleteMessagesAtIndexPaths indexPaths: [IndexPath], completion: ((Bool) -> ())?) {
        if indexPaths.isEmpty {
            return
        }

        var outdatedNodesMetadata = nodeMetadatas
        // Sort indicies in descending order to make sure deletion starts from the end of the array and remaining indicies are always valid.
        let isOrderedBefore: (IndexPath, IndexPath) -> Bool = {
            $0.compare($1) == ComparisonResult.orderedDescending
        }
        let sortedIndexPaths = indexPaths.sorted(by: isOrderedBefore)
        for indexPath in sortedIndexPaths {
            messages.remove(at: indexPath.item)
            outdatedNodesMetadata.remove(at: indexPath.item)
        }

        let updatedNodeMetadatas = nodeMetadataFactory.buildMetadatas(for: messages, currentUserID: _currentUserID)
        nodeMetadatas = updatedNodeMetadatas

        let reloadIndicies = Array<MessageCellNodeMetadata>.computeDiff(lhs: outdatedNodesMetadata, rhs: updatedNodeMetadatas)
        
        collectionNode.performBatchUpdates(
            {
                collectionNode.deleteItems(at: sortedIndexPaths)
                if !reloadIndicies.isEmpty {
                    collectionNode.reloadItems(at: IndexPath.createIndexPaths(section: 0, items: reloadIndicies))
                }
        },
            completion: completion)
    }
    
    public func collectionNode(collectionNode: ASCollectionNode, updateMessagesAtIndexPaths replacementMessages:[MessageData], indices: [Int], completion: ((Bool) -> ())?) {
        // update
        if indices.isEmpty || replacementMessages.isEmpty {
            return
        }
        
        for i in 0..<indices.count{
            
            messages[ indices[i] ] = replacementMessages[i]
        }

        let updatedNodeMetadatas = nodeMetadataFactory.buildMetadatas(for: messages, currentUserID: _currentUserID)
        nodeMetadatas = updatedNodeMetadatas
        
        collectionNode.performBatchUpdates(
            {
                collectionNode.reloadItems(at: IndexPath.createIndexPaths(section: 0, items: indices))
            },
            completion: completion)

    }
    
}

//MARK: Utils
private extension Array {

    mutating func insert(newElement: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        let index = insertionIndex(newElement: newElement, isOrderedBefore: isOrderedBefore)
        insert(newElement, at: index)
        return index
    }
    
    func insertionIndex(newElement: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var low = 0
        var high = count - 1
        
        while (low <= high) {
            let mid = low + ((high - low) / 2)
            let midElement = self[mid]
            
            if isOrderedBefore(midElement, newElement) {
                low = mid + 1
            } else if isOrderedBefore(newElement, midElement) {
                high = mid - 1
            } else {
                return mid
            }
        }
        return low
    }
    
    static func computeDiff<T>(lhs: Array<T>, rhs: Array<T>) -> [Int] where T: Equatable {
        assert(lhs.count == rhs.count, "Expect arrays with the same size.")
        var diffIndices = [Int]()
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                diffIndices.append(i)
            }
        }
        return diffIndices
    }
    
}

private extension IndexPath {
    
    static func createIndexPaths(section: Int, items: [Int]) -> [IndexPath] {
        return items.map() {
            IndexPath(item: $0, section: section)
        }
    }
    
}
