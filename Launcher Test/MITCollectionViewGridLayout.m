//
//  MITPagedFlowLayout.m
//  Launcher Test
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import "MITCollectionViewGridLayout.h"

NSString* const MITCollectionKindSectionHeader = @"MITCollectionKindSectionHeader";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindSectionFooter = @"MITCollectionKindSectionFooter";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindCellBadge = @"MITCollectionKindItemBadge";    // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}
NSString* const MITCollectionKindCell = @"MITCollectionKindCell";      // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}

@implementation MITCollectionViewGridLayout
{
    CGSize _cachedCollectionViewContentSize;
    CGSize _cachedPageSize;
    CGSize _numberOfPages;
    NSMutableDictionary *_cachedLayoutAttributes;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _contentInsets = UIEdgeInsetsZero;
    _referenceItemSize = CGSizeMake(64, 96);
    _referenceHeaderHeight = 0;
    _referenceFooterHeight = 0;
    
    _cachedCollectionViewContentSize = CGSizeZero;
    _cachedPageSize = CGSizeZero;
}

- (void)prepareLayout
{
    _cachedLayoutAttributes = [[NSMutableDictionary alloc] init];
    _cachedLayoutAttributes[MITCollectionKindCell] = [[NSMutableDictionary alloc] init];
    _cachedPageSize = self.collectionView.bounds.size;
    
    CGRect contentBounds = CGRectMake(0, 0, _cachedPageSize.width, _cachedPageSize.height);
    
    if (_referenceFooterHeight > 1.) {
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0
                                                           inSection:NSNotFound];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindSectionHeader
                                                                                                                            withIndexPath:headerIndexPath];
        CGRect frame = CGRectZero;
        CGFloat headerHeight = MIN(_referenceHeaderHeight,_cachedPageSize.height / 4.); // Limit to 25% of the view
        frame.size = CGSizeMake(_cachedPageSize.width, headerHeight);
        layoutAttributes.frame = frame;
        
        CGPoint center = layoutAttributes.center;
        center.x = _cachedPageSize.width / 2.;
        layoutAttributes.center = center;
        
        contentBounds.origin = CGPointMake(0, headerHeight);
        contentBounds.size = CGSizeMake(CGRectGetWidth(contentBounds),
                                        CGRectGetHeight(contentBounds) - headerHeight);
        _cachedLayoutAttributes[MITCollectionKindSectionHeader] = layoutAttributes;
    }
    
    if (_referenceFooterHeight > 1.) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1
                                                     inSection:NSNotFound];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindSectionFooter
                                                                                                                            withIndexPath:indexPath];
        CGRect frame = CGRectZero;
        CGFloat footerHeight = MIN(_referenceFooterHeight,_cachedPageSize.height / 4.); // Limit to 25% of the view
        frame.size = CGSizeMake(_cachedPageSize.width, footerHeight);
        frame.origin = CGPointMake(0, _cachedPageSize.height - footerHeight);
        layoutAttributes.frame = frame;
        
        CGPoint center = layoutAttributes.center;
        center.x = _cachedPageSize.width / 2.;
        layoutAttributes.center = center;
        
        contentBounds.size = CGSizeMake(CGRectGetWidth(contentBounds),
                                        CGRectGetHeight(contentBounds) - footerHeight);
        _cachedLayoutAttributes[MITCollectionKindSectionFooter] = layoutAttributes;
    }

    
    NSUInteger (^itemsForDimension)(CGFloat,CGFloat,CGFloat) = ^(CGFloat maxDistance, CGFloat itemDistance, CGFloat interItemPadding) {
        BOOL stop = NO;
        NSUInteger numberOfItems = floor(maxDistance / itemDistance);
        
        while (!stop && (numberOfItems > 0)) {
            CGFloat layoutDistance = (numberOfItems * itemDistance) + ((numberOfItems - 1.) * interItemPadding);
            if (layoutDistance > maxDistance) {
                --numberOfItems;
            } else {
                stop = YES;
            }
        }
        
        return numberOfItems;
    };
    
    contentBounds = UIEdgeInsetsInsetRect(contentBounds, _contentInsets);
    CGSize itemSize = CGSizeMake(MIN(_referenceItemSize.width,CGRectGetWidth(contentBounds)),
                                 MIN(_referenceItemSize.height,CGRectGetHeight(contentBounds)));
    
    NSUInteger numberOfItemsPerRow = itemsForDimension(CGRectGetWidth(contentBounds),itemSize.width,_minimumInterItemSpacingX);
    CGFloat interItemSpacingX = MAX(_minimumInterItemSpacingX, (_cachedPageSize.width / numberOfItemsPerRow) - itemSize.width);
    
    NSUInteger numberOfItemsPerColumn = itemsForDimension(CGRectGetHeight(contentBounds),itemSize.height,_minimumInterItemSpacingY);
    CGFloat interItemSpacingY = MAX(_minimumInterItemSpacingY, (_cachedPageSize.height / numberOfItemsPerColumn) - itemSize.height);
    
    NSUInteger pageCount = 0;
    NSUInteger numberOfSections = [self.collectionView numberOfSections];
    
    for (NSUInteger section = 0; section < numberOfSections; ++section) {
        NSUInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
        CGPoint cellOrigin = CGPointZero;
        
        for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
            NSUInteger column = item % numberOfItemsPerRow;
            NSUInteger row = item / numberOfItemsPerColumn;
            
            if ((row == 0) && (column == 0)) {
                cellOrigin.x = (pageCount * _cachedPageSize.width) + CGRectGetMinX(contentBounds);
                cellOrigin.y = CGRectGetMinY(contentBounds);
                ++pageCount;
            } else {
                cellOrigin.x = (column * (itemSize.width + interItemSpacingX));
                cellOrigin.y = (row * (itemSize.height + interItemSpacingY));
            }
            
            CGRect cellFrame = CGRectZero;
            cellFrame.origin = cellOrigin;
            cellFrame.size = itemSize;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item
                                                         inSection:section];
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttributes.frame = cellFrame;
            
            NSMutableDictionary *cellsLayoutAttributes = _cachedLayoutAttributes[MITCollectionKindCell];
            cellsLayoutAttributes[indexPath] = layoutAttributes;
        }
    }
    
    _cachedCollectionViewContentSize.height = _cachedPageSize.height;
    _cachedCollectionViewContentSize.width = _cachedPageSize.width + (MAX(pageCount - 1, 0) * _cachedPageSize.width);
}

- (CGSize)collectionViewContentSize
{
    return _cachedCollectionViewContentSize;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cachedItemLayoutAttributes = _cachedLayoutAttributes[MITCollectionKindCell];
    
    return cachedItemLayoutAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                    atIndexPath:(NSIndexPath *)indexPath
{
    if ([MITCollectionKindSectionHeader isEqualToString:kind]) {
        return _cachedLayoutAttributes[MITCollectionKindSectionHeader];
    } else if ([MITCollectionKindSectionFooter isEqualToString:kind]) {
        return _cachedLayoutAttributes[MITCollectionKindSectionFooter];
    } else {
        return nil;
    }
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    NSMutableArray *layoutAttributesInRect = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *headerAttributes = _cachedLayoutAttributes[MITCollectionKindSectionHeader];
    if (headerAttributes) {
        headerAttributes.transform = CGAffineTransformMakeTranslation(contentOffset.x, 0);
        [layoutAttributesInRect addObject:headerAttributes];
    }
    
    UICollectionViewLayoutAttributes *footerAttributes = _cachedLayoutAttributes[MITCollectionKindSectionFooter];
    if (footerAttributes) {
        footerAttributes.transform = CGAffineTransformMakeTranslation(contentOffset.x, 0);
        [layoutAttributesInRect addObject:footerAttributes];
    }
    
    NSDictionary *cachedItemAttributes = _cachedLayoutAttributes[MITCollectionKindCell];
    for (UICollectionViewLayoutAttributes *layoutAttributes in [cachedItemAttributes allValues]) {
        if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
            [layoutAttributesInRect addObject:layoutAttributes];
        }
    }
    
    return layoutAttributesInRect;
}

#pragma mark - Property Implementations
- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self invalidateLayout];
}

- (void)setReferenceItemSize:(CGSize)referenceItemSize
{
    _referenceItemSize = referenceItemSize;
    [self invalidateLayout];
}

- (void)setReferenceHeaderHeight:(CGFloat)referenceHeaderHeight
{
    _referenceHeaderHeight = referenceHeaderHeight;
    [self invalidateLayout];
}

- (void)setReferenceFooterHeight:(CGFloat)referenceFooterHeight
{
    _referenceFooterHeight = referenceFooterHeight;
    [self invalidateLayout];
}

@end
