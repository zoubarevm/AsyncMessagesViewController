//
//  AsyncMessagesViewController.swift
//  AsyncMessagesViewController
//
//  Created by Huy Nguyen on 12/02/15.
//  Copyright (c) 2015 Huy Nguyen. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SlackTextViewController

open class AsyncMessagesViewController: SLKTextViewController {

    public let dataSource: AsyncMessagesCollectionViewDataSource
    //public let delegate: ASCollectionDelegate
    open let asyncCollectionNode: ASCollectionNode
    //public let asyncCollectionView: asyncCol
    public let cacheImages = true;
    
    override open var collectionView: ASCollectionView {
        return scrollView as! ASCollectionView
    }

    public init?(dataSource: AsyncMessagesCollectionViewDataSource, delegate: ASCollectionDelegate?) {
        self.dataSource = dataSource
        //self.delegate = delegate
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        asyncCollectionNode = ASCollectionNode(collectionViewLayout: layout)
        let asyncCollectionView = asyncCollectionNode.view
        
        asyncCollectionView.backgroundColor = UIColor.white
        asyncCollectionView.scrollsToTop = true
        
        
        asyncCollectionNode.dataSource = dataSource
        asyncCollectionNode.delegate = delegate
        
        //
        super.init(scrollView: asyncCollectionView)
        
        isInverted = false
    }
    
    open override func viewDidLoad() {
        //collectionView.backgroundColor = UIColor.red;
        super.viewDidLoad();
        let longPressGesture  = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.delaysTouchesBegan = true;
        
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gesture : UILongPressGestureRecognizer!){
        if gesture.state != .began {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            //_ = self.collectionView.cellForItem(at: indexPath)
            // do stuff with the cell
            self.didLongPressItem(indexPath)
            
        } else {
            print("couldn't find index path")
        }
    }
    
    open func didLongPressItem(_ indexPath: IndexPath){
        print("found the index path after long press at \(indexPath.row)")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewWillLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, 5, 0)
        asyncCollectionNode.contentInset = insets
        collectionView.scrollIndicatorInsets = insets

        super.viewWillLayoutSubviews()
    }
    
    public func scrollCollectionViewToBottom(_ animated: Bool = true) {
        let numberOfItems = dataSource.collectionNode!(asyncCollectionNode, numberOfItemsInSection: 0)
        if numberOfItems > 0 {
            let lastItemIndexPath = IndexPath(item: numberOfItems - 1, section: 0)
            asyncCollectionNode.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
        }
    }
    
}
