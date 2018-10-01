//
//  CollectionViewPagingLayout.swift
//  LongShot
//
//  Created by Brandon on 2018-01-01.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation

public extension UICollectionView {

    /// itemSpacing - space between each item
    /// itemPeakAmount - how much of the next item to show/peak in pixels
    /// itemsPerRow - number of items per row to show in a horizontal collection view
    /// insets - section insets if any
    public func widthForItemWithPeaking(_ itemSpacing: CGFloat, itemPeakAmount: CGFloat, itemsPerRow: Int = 1, insets: UIEdgeInsets = .zero) -> CGFloat {
        var width = self.bounds.width - itemSpacing * CGFloat(itemsPerRow - 1)
        width -= insets.left + insets.right
        width -= itemPeakAmount
        return floor(width / CGFloat(itemsPerRow))
    }
    
    /// velocity - the velocity of the scrollView in `scrollViewWillEndDragging`
    /// targetContentOffset - the target offset of the scrollView in `scrollViewWillEndDragging`
    public func pageIndexForPaging(_ velocity: CGPoint, targetContentOffset: CGPoint) -> Int? {
        var direction = UICollectionView.ScrollDirection.vertical
        
        if let scrollDirection = (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection {
            direction = scrollDirection
        }
        
        if direction == .horizontal {
            let offset = self.collectionViewLayout.horizontalTargetContentOffset(forProposedContentOffset: targetContentOffset, withScrollingVelocity: velocity)
            
            let itemCenterOffset = offset.x + (self.bounds.width * CGFloat(0.50))
            if let indexPath = self.indexPathForItem(at: CGPoint(x: itemCenterOffset, y: self.center.y)) {
                return Int(indexPath.row)
            }
            return nil
        }

        let offset = self.collectionViewLayout.verticalTargetContentOffset(forProposedContentOffset: targetContentOffset, withScrollingVelocity: velocity)
        
        let itemCenterOffset = offset.y + (self.bounds.height * CGFloat(0.50))
        if let indexPath = self.indexPathForItem(at: CGPoint(x: self.center.x, y: itemCenterOffset)) {
            return Int(indexPath.row)
        }
        return nil
    }
    
    /// velocity - the velocity of the scrollView in `scrollViewWillEndDragging`
    /// targetContentOffset - the target offset of the scrollView in `scrollViewWillEndDragging`
    public func contentOffsetForPaging(_ velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var direction = UICollectionView.ScrollDirection.vertical
        
        if let scrollDirection = (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection {
            direction = scrollDirection
        }
        
        if direction == .horizontal {
            let offset = self.collectionViewLayout.horizontalTargetContentOffset(forProposedContentOffset: targetContentOffset.pointee, withScrollingVelocity: velocity)
            
            targetContentOffset.pointee.x = offset.x
            self.setContentOffset(CGPoint(x: CGFloat(targetContentOffset.pointee.x), y: self.contentOffset.y), animated: true)
        }
        else {
            let offset = self.collectionViewLayout.verticalTargetContentOffset(forProposedContentOffset: targetContentOffset.pointee, withScrollingVelocity: velocity)
            
            targetContentOffset.pointee.y = offset.y
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: CGFloat(targetContentOffset.pointee.y)), animated: true)
        }
    }
}

public extension UICollectionViewLayout {
    
    public func horizontalTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let rectBounds: CGRect = self.collectionView!.bounds
        let halfWidth: CGFloat = rectBounds.size.width * CGFloat(0.50)
        let proposedContentOffsetCenterX: CGFloat = proposedContentOffset.x + halfWidth
        let proposedRect: CGRect = self.collectionView!.bounds
        let attributesArray = self.layoutAttributesForElements(in: proposedRect)!
        var candidateAttributes:UICollectionViewLayoutAttributes?
        
        for layoutAttributes : AnyObject in attributesArray {
            if let layoutAttributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                
                if layoutAttributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                    continue
                }
                
                if candidateAttributes == nil {
                    candidateAttributes = layoutAttributes
                    continue
                }
                
                if fabsf(Float(layoutAttributes.center.x) - Float(proposedContentOffsetCenterX)) < fabsf(Float(candidateAttributes!.center.x) - Float(proposedContentOffsetCenterX)) {
                    candidateAttributes = layoutAttributes
                }
            }
        }
        
        if attributesArray.count == 0 {
            return CGPoint(x: proposedContentOffset.x - halfWidth * 2,y: proposedContentOffset.y)
        }
        return CGPoint(x: candidateAttributes!.center.x - halfWidth, y: proposedContentOffset.y)
    }
    
    public func verticalTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let rectBounds: CGRect = self.collectionView!.bounds
        let halfHeight: CGFloat = rectBounds.size.height * CGFloat(0.50)
        let proposedContentOffsetCenterY: CGFloat = proposedContentOffset.y + halfHeight
        let proposedRect: CGRect = self.collectionView!.bounds
        let attributesArray = self.layoutAttributesForElements(in: proposedRect)!
        var candidateAttributes:UICollectionViewLayoutAttributes?
        
        for layoutAttributes : AnyObject in attributesArray {
            
            if let layoutAttributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                
                if layoutAttributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                    continue
                }
                
                if candidateAttributes == nil {
                    candidateAttributes = layoutAttributes
                    continue
                }
                
                if fabsf(Float(layoutAttributes.center.y) - Float(proposedContentOffsetCenterY)) < fabsf(Float(candidateAttributes!.center.y) - Float(proposedContentOffsetCenterY)) {
                    candidateAttributes = layoutAttributes
                }
            }
        }
        
        if attributesArray.count == 0 {
            return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y - halfHeight * 2)
        }
        return CGPoint(x: proposedContentOffset.x, y: candidateAttributes!.center.y - halfHeight)
    }
}

open class HorizontalPagingFlowLayout : UICollectionViewFlowLayout {
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        return self.horizontalTargetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
}

open class VerticalPagingFlowLayout : UICollectionViewFlowLayout {
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        return self.verticalTargetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
}
