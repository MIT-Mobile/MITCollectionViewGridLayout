//
//  MITPagedFlowLayout.h
//  Launcher Test
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString* const MITCollectionKindSectionHeader;
extern NSString* const MITCollectionKindSectionFooter;
extern NSString* const MITCollectionKindItemBadge;

@protocol MITCollectionViewDelegateGridLayout;

@interface MITCollectionViewGridLayout : UICollectionViewLayout
@property (nonatomic) UIEdgeInsets contentInsets;

@property (nonatomic) CGSize minimumInterItemSpacing;

/** The size of each cell in the view. */
@property (nonatomic) CGSize referenceItemSize;

/** Size of the header. If the size is set to CGSizeZero,
 a header will not be added. Both dimensions will be bounded
 to the current page size; specifying CGFLOAT_MAX, for example,
 will maximize the size in a given dimension.
 */
@property (nonatomic) CGFloat referenceHeaderHeight;

/** Desired height of the footer
 */
@property (nonatomic) CGFloat referenceFooterHeight;

@end

@protocol MITCollectionViewDelegateGridLayout <UICollectionViewDelegate>

@end