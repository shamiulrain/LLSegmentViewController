//
//  LLSegmentCtl.swift
//  LLSegmentViewController
//
//  Created by lilin on 2018/12/18.
//  Copyright © 2018年 lilin. All rights reserved.
//

import UIKit
@objc  protocol LLSegmentCtlViewDelegate : NSObjectProtocol {
    @objc optional func segMegmentCtlView(segMegmentCtlView: LLSegmentCtlView, leftItemView: LLSegmentCtlItemView,rightItemView:LLSegmentCtlItemView,percent:CGFloat)
    @objc optional func segMegmentCtlView(segMegmentCtlView: LLSegmentCtlView, itemView: LLSegmentCtlItemView,extraGapAtIndex:NSInteger) -> CGFloat
    @objc optional func segMegmentCtlView(segMegmentCtlView: LLSegmentCtlView, itemView: LLSegmentCtlItemView,selectedAt:NSInteger)

}



public class LLSegmentCtlView: UIView {
    public var contentOffsetAnimation = true
    var ctlModels:[UIViewController]!
    var itemViews = [LLSegmentCtlItemView]()
    var delegate:LLSegmentCtlViewDelegate?
    let segMegmentScrollerView = UIScrollView(frame: CGRect.zero)
    private (set) var indicatorView = LLIndicatorView()
    private let LLSegmentTitleCellIdentifier = "LLSegmentTitleCellIdentifier"
    private let associateScrollerViewObserverKeyPath = "contentOffset"
    private var selectedPage = 0
    private var indicatorLayoutOnBottom = true
    public weak var associateScrollerView:UIScrollView? {
        didSet{
            associateScrollerView?.addObserver(self, forKeyPath: associateScrollerViewObserverKeyPath, options: [.new,.old], context: nil)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        associateScrollerView?.removeObserver(self, forKeyPath: associateScrollerViewObserverKeyPath)
    }
    
    @objc func itemViewClick(gesture:UIGestureRecognizer) {
        if let selectedItemView = gesture.view as? LLSegmentCtlItemView,
            let selectedIndex = itemViews.index(of: selectedItemView)?.hashValue,
            let associateScrollerView = associateScrollerView{
            let preSeletedIndex = Int(associateScrollerView.contentOffset.x / associateScrollerView.bounds.width)
            let preSelectedItemView = getItemView(atIndex: preSeletedIndex)

            //点击的是当前的
            if selectedIndex == preSeletedIndex {
                return
            }
            
            delegate?.segMegmentCtlView?(segMegmentCtlView: self, itemView: selectedItemView, selectedAt: selectedIndex)
            
            if let preSelectedItemView = preSelectedItemView {
                var leftItemView = selectedItemView
                var rightItemView = preSelectedItemView
                if leftItemView.frame.origin.x > rightItemView.frame.origin.x {
                    leftItemView = preSelectedItemView
                    rightItemView = selectedItemView
                }
                
                if fabs(Double(preSeletedIndex - selectedIndex)) == 1 && contentOffsetAnimation{
                    let offset = CGPoint.init(x: CGFloat(selectedIndex) * associateScrollerView.bounds.width, y: 0)
                    associateScrollerView.setContentOffset(offset, animated: true)
                }else{
                    segMegmentScrollerView.scrollRectToVisible(selectedItemView.frame, animated: contentOffsetAnimation)
                    
                    selectedItemView.percentChange(percent: 1)
                    preSelectedItemView.percentChange(percent: 0)
                    
                    let indicatorViewCenter = indicatorView.center
                    let animationTime = contentOffsetAnimation ? 0.25 : 0
                    UIView.animate(withDuration: animationTime) {
                        self.indicatorView.reloadIndicatorViewLayout(segMegmentCtlView: self, leftItemView: leftItemView, rightItemView: rightItemView)
                        self.indicatorView.center = CGPoint.init(x: selectedItemView.center.x, y: indicatorViewCenter.y)
                    }
            
                    //TODO:
                    let offset = CGPoint.init(x: CGFloat(selectedIndex) * associateScrollerView.bounds.width, y: 0)
                    associateScrollerView.setContentOffset(offset, animated: false)
                }
                
            }
        }
    }
}

extension LLSegmentCtlView{
    public func reloadIndicatorView(indicatorView:LLIndicatorView){
        self.indicatorView.removeFromSuperview()
        let oldIndicatorViewCenterX = self.indicatorView.center.x
        var newIndicatorViewCenter = indicatorView.center
        newIndicatorViewCenter.x = oldIndicatorViewCenterX
        indicatorView.center = newIndicatorViewCenter
        segMegmentScrollerView.addSubview(indicatorView)
        self.indicatorView = indicatorView
    }
    
    public func reloadIndicator(isOnBottom:Bool) {
        self.indicatorLayoutOnBottom = isOnBottom
        var indicatorViewCenter = indicatorView.center
        if isOnBottom {
            indicatorViewCenter.y =  segMegmentScrollerView.bounds.height - indicatorView.bounds.height/2
        }else{
            indicatorViewCenter.y = indicatorView.bounds.height/2
        }
        indicatorView.center = indicatorViewCenter
    }
}

extension LLSegmentCtlView{
    public func reloadData(itemSpacing:CGFloat,segmentItemViewClass: LLSegmentCtlItemView.Type,itemViewStyle:LLSegmentCtlItemViewStyle,defaultSelectedIndex:NSInteger = 0) {
        for subView in segMegmentScrollerView.subviews{
            if subView != indicatorView {
                subView.removeFromSuperview()
            }
        }
        itemViews.removeAll()
        var lastItemView:LLSegmentCtlItemView? = nil
        for (index,ctl) in ctlModels.enumerated() {
            let segmentCtlItemView = segmentItemViewClass.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: bounds.height))
            segmentCtlItemView.associateViewCtl = ctl
            segmentCtlItemView.setSegmentItemViewStyle(itemViewStyle: itemViewStyle)
            segmentCtlItemView.percentChange(percent: 0)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemViewClick(gesture:)))
            segmentCtlItemView.addGestureRecognizer(tapGesture)
            
            //size
            var segmentCtlItemViewFrame = segmentCtlItemView.frame
            segmentCtlItemViewFrame.size.width = segmentCtlItemView.itemWidth()
            segmentCtlItemViewFrame.size.height = self.bounds.height
            
            //origin
            if let lastItemView = lastItemView {
                var itemGap = itemSpacing
                if let gap = delegate?.segMegmentCtlView?(segMegmentCtlView: self, itemView: segmentCtlItemView, extraGapAtIndex: index) {
                    itemGap += gap
                }
                segmentCtlItemViewFrame.origin.x = lastItemView.frame.maxX + itemGap
            }
            segmentCtlItemViewFrame.origin.y = (bounds.height - segmentCtlItemViewFrame.size.height) / 2
            
            segmentCtlItemView.frame = segmentCtlItemViewFrame
            segMegmentScrollerView.addSubview(segmentCtlItemView)
            itemViews.append(segmentCtlItemView)
            lastItemView = segmentCtlItemView
        }
        segMegmentScrollerView.contentSize = CGSize.init(width: lastItemView?.frame.maxX ?? bounds.width, height: bounds.height)
        
        //初始化设置状态和位置
        segMegmentScrollerView.addSubview(indicatorView)
        if let firstItemView = getItemView(atIndex: 0) {
            var y = indicatorView.bounds.height/2
            if self.indicatorLayoutOnBottom {
                y = segMegmentScrollerView.bounds.height - indicatorView.bounds.height/2
            }
            indicatorView.center = CGPoint.init(x:  firstItemView.center.x, y: y)
        }
        
        if let defaultSelectedItemView = getItemView(atIndex: defaultSelectedIndex) {
            defaultSelectedItemView.percentChange(percent: 1)
        }
        
        if let leftItemView = getItemView(atIndex: 0),
            let rightItemView = getItemView(atIndex: 1){
            delegate?.segMegmentCtlView?(segMegmentCtlView: self, leftItemView: leftItemView, rightItemView: rightItemView, percent: 0)
        }
    }
}

extension LLSegmentCtlView{
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == associateScrollerViewObserverKeyPath ,
            let newContentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint,
            let oldContentOffset = change?[NSKeyValueChangeKey.oldKey] as? CGPoint,
            let scrollView = associateScrollerView{
            if  scrollView.contentSize.width != 0 && scrollView.bounds.width != 0{
                layout(newContentOffset: newContentOffset, oldContentOffset: oldContentOffset, scrollView: scrollView)
            }
        }
    }
    
    
    func layout(newContentOffset:CGPoint,oldContentOffset:CGPoint,scrollView:UIScrollView) {
        let isScrollerToRight = (newContentOffset.x - oldContentOffset.x > 0)
        let leftFirstItem = Int(newContentOffset.x / scrollView.bounds.width)
        var currentItem = 0
        var targetItem = 0
        var percent:CGFloat = 0
        if isScrollerToRight {
            currentItem = leftFirstItem
            targetItem = leftFirstItem + 1
            percent = 1 - (CGFloat(targetItem)*scrollView.bounds.width - newContentOffset.x) / scrollView.bounds.width
        }else{
            currentItem = leftFirstItem + 1
            targetItem = leftFirstItem
            percent = (newContentOffset.x - CGFloat(targetItem)*scrollView.bounds.width) / scrollView.bounds.width
        }
        
        if (currentItem < 0 || currentItem >= ctlModels.count) || (targetItem < 0 || targetItem >= ctlModels.count){
            return
        }
        
        let leftItemIndex = Int(newContentOffset.x / scrollView.bounds.width)
        let rightItemIndex = leftFirstItem + 1
        if let leftItemView = getItemView(atIndex: leftItemIndex),
            let rightItemView = getItemView(atIndex: rightItemIndex) {
            reload(leftItemView: leftItemView, rightItemView: rightItemView, percent: percent)
        }
    }
    
    func reload(leftItemView:LLSegmentCtlItemView,rightItemView:LLSegmentCtlItemView,percent:CGFloat) {
        let leftPercent = 1 - percent
        let rightPercent = percent
        leftItemView.percentChange(percent: leftPercent)
        rightItemView.percentChange(percent: rightPercent)
        
        var x:CGFloat = 0
        x = interpolationFrom(from: leftItemView.center.x, to: rightItemView.center.x, percent: percent)
        indicatorView.center = CGPoint.init(x: x , y: 0)
        reloadIndicator(isOnBottom: self.indicatorLayoutOnBottom)
        indicatorView.reloadIndicatorViewLayout(segMegmentCtlView: self, leftItemView: leftItemView, rightItemView: rightItemView)
        delegate?.segMegmentCtlView?(segMegmentCtlView: self, leftItemView: leftItemView, rightItemView: rightItemView, percent: percent)
    }
    
    func getItemView(atIndex:NSInteger) -> LLSegmentCtlItemView? {
        if atIndex < 0 || atIndex >= itemViews.count {
            return nil
        }
        return itemViews[atIndex]
    }
}


extension LLSegmentCtlView{
    func initSubviews() {
        segMegmentScrollerView.backgroundColor = UIColor.clear
        segMegmentScrollerView.frame = bounds
        segMegmentScrollerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        addSubview(segMegmentScrollerView)
        segMegmentScrollerView.showsHorizontalScrollIndicator = false
        segMegmentScrollerView.showsVerticalScrollIndicator = false
        segMegmentScrollerView.bounces = false
        
        if #available(iOS 11.0, *) {
            segMegmentScrollerView.contentInsetAdjustmentBehavior = .never
        }
        
        indicatorView.backgroundColor = UIColor.black
        indicatorView.frame = CGRect.init(x: 0, y: 0, width: 10, height: 3)
        segMegmentScrollerView.addSubview(indicatorView)
    }
}
