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
NSString* const MITCollectionKindCellBadge = @"MITCollectionKindItemBadge";          // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}
NSString* const MITCollectionKindCell = @"MITCollectionKindCell";                    // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}

@implementation MITCollectionViewGridLayout
{
    CGSize _cachedCollectionViewContentSize;
    CGSize _cachedPageSize;
    CGSize _numberOfPages;
    NSMutableDictionary *_cachedLayoutAttributes;
    BOOL _headersInvalidatedLayout;
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
    _contentInsets = UIEdgeInsetsMake(4., 8., 4., 8.);
    _referenceItemSize = CGSizeMake(64, 88);
    _referenceHeaderHeight = 0;
    _referenceFooterHeight = 0;
    _headersInvalidatedLayout = NO;
    
    _cachedCollectionViewContentSize = CGSizeZero;
    _cachedPageSize = CGSizeZero;
    _cachedLayoutAttributes = [[NSMutableDictionary alloc] init];
}

- (void)prepareLayout
{
    _cachedPageSize = self.collectionView.bounds.size;
    
    CGRect contentBounds = CGRectMake(0, 0, _cachedPageSize.width, _cachedPageSize.height);
    
    if (_referenceHeaderHeight > 1.) {
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0
                                                           inSection:0];
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
                                                     inSection:0];
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
    
    _headersInvalidatedLayout = NO;
    
    if ([_cachedLayoutAttributes[MITCollectionKindCell] count] == 0) {
        _cachedLayoutAttributes[MITCollectionKindCell] = [[NSMutableDictionary alloc] init];
        
        contentBounds = UIEdgeInsetsInsetRect(contentBounds, _contentInsets);
        
        CGSize itemSize = CGSizeMake(MIN(_referenceItemSize.width,CGRectGetWidth(contentBounds)),
                                     MIN(_referenceItemSize.height,CGRectGetHeight(contentBounds)));
        
        
        NSUInteger numberOfItemsPerRow = [self numberOfItemsInDimension:CGRectGetWidth(contentBounds)
                                                          itemDimension:itemSize.width
                                                       interItemPadding:_minimumInterItemSpacingX];
        CGFloat interItemSpacingX = 0;
        if (numberOfItemsPerRow > 1) {
            interItemSpacingX = floor((CGRectGetWidth(contentBounds) -
                                 (numberOfItemsPerRow * itemSize.width)) /
                                (numberOfItemsPerRow - 1));
        }
        
        NSUInteger numberOfItemsPerColumn = [self numberOfItemsInDimension:CGRectGetHeight(contentBounds)
                                                             itemDimension:itemSize.height
                                                          interItemPadding:_minimumInterItemSpacingY];
        CGFloat interItemSpacingY = 0;
        if (numberOfItemsPerColumn > 1) {
            interItemSpacingY = floor((CGRectGetHeight(contentBounds) -
                                 (numberOfItemsPerColumn * itemSize.height)) /
                                (numberOfItemsPerColumn - 1));
        }

        
        NSUInteger pageCount = 0;
        NSUInteger numberOfSections = [self.collectionView numberOfSections];
        
        for (NSUInteger section = 0; section < numberOfSections; ++section) {
            NSUInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            CGPoint frameOrigin = CGPointZero;
            
            for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
                NSUInteger column = item % numberOfItemsPerRow;
                NSUInteger row = (item / numberOfItemsPerRow) % numberOfItemsPerColumn;

                if ((row == 0) && (column == 0)) {
                    frameOrigin.x = (pageCount * _cachedPageSize.width);
                    frameOrigin.y = 0;
                    ++pageCount;
                }
                
                CGPoint cellOrigin = CGPointMake(column * (itemSize.width + interItemSpacingX),
                                                 row * (itemSize.height + interItemSpacingY));
                cellOrigin.x += CGRectGetMinX(contentBounds) + frameOrigin.x;
                cellOrigin.y += CGRectGetMinY(contentBounds) + frameOrigin.y;
                
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
}

- (NSUInteger)numberOfItemsInDimension:(CGFloat)maxDimension
                         itemDimension:(CGFloat)itemDimension
                      interItemPadding:(CGFloat)padding
{
    CGFloat numberOfItems = ceil(maxDimension / itemDimension);
    CGFloat calculatedSize = numberOfItems * itemDimension;
    CGFloat calculatedPadding = 0;
    
    while ((calculatedSize > maxDimension) || (calculatedPadding < padding)) {
        --numberOfItems;
        calculatedPadding = round((maxDimension - (numberOfItems * itemDimension)) / (numberOfItems - 1.));
        calculatedSize = (numberOfItems * itemDimension) + (MAX(numberOfItems - 1,0) * calculatedPadding);
    }
    
    return numberOfItems;
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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    [self invalidateHeaderLayout];
    return NO;
}

- (void)invalidateHeaderLayout
{
    _headersInvalidatedLayout = YES;
    [_cachedLayoutAttributes removeObjectForKey:MITCollectionKindSectionHeader];
    [_cachedLayoutAttributes removeObjectForKey:MITCollectionKindSectionFooter];
    
    [self invalidateLayout];
}

- (void)invalidateLayout {
    [super invalidateLayout];
    
    if (!_headersInvalidatedLayout) {
        [_cachedLayoutAttributes removeObjectForKey:MITCollectionKindCell];
    }
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
