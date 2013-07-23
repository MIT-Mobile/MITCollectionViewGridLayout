//
//  MITPagedFlowLayout.h
//  Launcher Test
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString* const MITCollectionKindFloatingHeader;
extern NSString* const MITCollectionKindFloatingFooter;

@protocol MITCollectionViewDelegateGridLayout;

@interface MITCollectionViewGridLayout : UICollectionViewLayout
@property (nonatomic) UIEdgeInsets contentInsets;

/** The minimum amount of spacing between cells. The
 *  value of 'width' is used as horizontal spacing and
 *  'height' defined the vertical spacing. The actual
 *  spacing may be larger depending on the number and size
 *  of the cells and thefloating views.
 */
@property (nonatomic) CGSize minimumInterItemSpacing;

/** The size of each cell in the view. Setting this
 *  to a size with 0 in either (or both) dimension,
 *  will result in undefined behavior.
 *
 *  If a full-page cell is needed, assign a
 *  CGSize object with its width and height set
 *  to CGFLOAT_MAX.
 */
@property (nonatomic) CGSize referenceItemSize;

/** Size of the header. If the size is set to '0',
 a header will not be added. The maximum height of the header
 is limited to 25% of the collection view's bounds' height.
 */
@property (nonatomic) CGFloat referenceHeaderHeight;

/** Desired height of the footer. If the size is set to '0',
 a header will not be added. The maximum height of the footer
 is limited to 25% of the collection view's bounds' height.
 */
@property (nonatomic) CGFloat referenceFooterHeight;

@end

@protocol MITCollectionViewDelegateGridLayout <UICollectionViewDelegate>

@end