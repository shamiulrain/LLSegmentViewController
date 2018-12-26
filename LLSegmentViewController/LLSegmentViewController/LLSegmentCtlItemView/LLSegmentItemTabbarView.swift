//
//  LLSegmentItemTabbarView.swift
//  LLSegmentViewController
//
//  Created by lilin on 2018/12/26.
//  Copyright © 2018年 lilin. All rights reserved.
//

import UIKit

public class LLSegmentItemTabbarViewStyle:LLSegmentItemTitleViewStyle {
    var titleImgeGap:CGFloat = 0
    var titleBottomGap:CGFloat = 0
}


class LLSegmentItemTabbarView: LLSegmentCtlItemView {
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let badgeValueLabel = UILabel()
    let tabbarItemButton = UIButton()
    private var tabbarViewStyle = LLSegmentItemTabbarViewStyle()
    required init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(imageView)
        
//        badgeValueLabel.backgroundColor = UIColor.red
//        badgeValueLabel.textAlignment = .center
//        badgeValueLabel.textColor = UIColor.white
//        badgeValueLabel.font = UIFont.systemFont(ofSize: 12)
//        badgeValueLabel.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
//        badgeValueLabel.center = CGPoint.init(x: bounds.width - 10, y: 10)
//        addSubview(badgeValueLabel)
        
        backgroundColor = LLRandomRGB()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var associateViewCtl: UIViewController? {
        didSet{
            if associateViewCtl?.tabBarItem.title == nil {
                titleLabel.text = associateViewCtl?.title
            }else{
                titleLabel.text = associateViewCtl?.tabBarItem.title
            }
        }
    }
    
    override func percentChange(percent: CGFloat) {
        super.percentChange(percent: percent)
        titleLabel.textColor = interpolationColorFrom(fromColor:tabbarViewStyle.unSelectedColor, toColor:tabbarViewStyle.selectedColor, percent: percent)
        if percent == 1 {
            imageView.image = associateViewCtl?.tabBarItem.selectedImage
        }else{
            imageView.image = associateViewCtl?.tabBarItem.image
        }
    }
    
    override func itemWidth() -> CGFloat {
        if tabbarViewStyle.itemWidth == LLSegmentAutomaticDimension {
            var titleLableWidth = associateViewCtl?.title?.LLGetStrSize(font: tabbarViewStyle.titleFontSize, w: 1000, h: 1000).width ?? 0
            titleLableWidth = titleLableWidth + 2*tabbarViewStyle.extraTitleSpace
            return titleLableWidth
        }else{
            return tabbarViewStyle.itemWidth
        }
    }
    
    override func setSegmentItemViewStyle(itemViewStyle: LLSegmentCtlItemViewStyle) {
        if let itemViewStyle = itemViewStyle as? LLSegmentItemTabbarViewStyle {
            self.tabbarViewStyle = itemViewStyle
            titleLabel.textAlignment = .center
            titleLabel.textColor = itemViewStyle.unSelectedColor
            titleLabel.font = UIFont.systemFont(ofSize: itemViewStyle.titleFontSize)
            
            titleLabel.frame = CGRect.init(x: 0, y: bounds.height - itemViewStyle.titleBottomGap - titleLabel.font.lineHeight, width: bounds.width, height: titleLabel.font.lineHeight)
            titleLabel.autoresizingMask = [.flexibleWidth,.flexibleTopMargin]
            
            imageView.contentMode = .bottom
            imageView.frame = CGRect.init(x: 0, y: 0, width: bounds.width, height: titleLabel.frame.origin.y - tabbarViewStyle.titleImgeGap)
            imageView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            
        }
    }

}