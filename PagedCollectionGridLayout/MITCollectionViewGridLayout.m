//
//  MITPagedFlowLayout.m
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import "MITCollectionViewGridLayout.h"

typedef struct {
    CGFloat spacing;
    NSUInteger numberOfItems;
} MITAxisGridLayout;

const MITAxisGridLayout MITAxisGridLayoutZero = {.spacing = 0., .numberOfItems = 0};

NSString* const MITCollectionKindSectionHeader = @"MITCollectionKindSectionHeader";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindSectionFooter = @"MITCollectionKindSectionFooter";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindItemBadge = @"MITCollectionKindItemBadge";          // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}
NSString* const MITCollectionKindCell = @"MITCollectionKindCell";                    // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}

NSString* const MITCollectionSectionIndexKey = @"MITCollectionSectionIndex";
NSString* const MITCollectionPageLayoutKey = @"MITCollectionPageLayout";

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
    
    if (!_cachedLayoutAttributes[MITCollectionKindSectionHeader] && (_referenceHeaderHeight > 1.)) {
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0
                                                           inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindSectionHeader
                                                                                                                            withIndexPath:headerIndexPath];
        CGRect frame = CGRectZero;
        
        // Limit to 25% of the view
        CGFloat headerHeight = MIN(_referenceHeaderHeight,_cachedPageSize.height / 4.);
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
    
    if (!_cachedLayoutAttributes[MITCollectionKindSectionFooter] && (_referenceFooterHeight > 1.)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1
                                                     inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindSectionFooter
                                                                                                                            withIndexPath:indexPath];
        CGRect frame = CGRectZero;
        
        // Limit to 25% of the view
        CGFloat footerHeight = MIN(_referenceFooterHeight,_cachedPageSize.height / 4.);
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
        
        
        MITAxisGridLayout horizontalLayout = [self axisGridLayoutForWidth:CGRectGetWidth(contentBounds)
                                                                itemWidth:itemSize.width
                                                         interItemSpacing:_minimumInterItemSpacing.width];
        MITAxisGridLayout verticalLayout = [self axisGridLayoutForWidth:CGRectGetHeight(contentBounds)
                                                              itemWidth:itemSize.height
                                                       interItemSpacing:_minimumInterItemSpacing.height];
        NSUInteger pageCount = 0;
        NSUInteger numberOfSections = [self.collectionView numberOfSections];
        
        for (NSUInteger section = 0; section < numberOfSections; ++section) {
            NSUInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            CGPoint frameOrigin = CGPointZero;
            
            for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
                NSUInteger column = item % horizontalLayout.numberOfItems;
                NSUInteger row = (item / horizontalLayout.numberOfItems) % verticalLayout.numberOfItems;
                
                if ((row == 0) && (column == 0)) {
                    frameOrigin.x = (pageCount * _cachedPageSize.width);
                    frameOrigin.y = 0;
                    ++pageCount;
                }
                
                CGPoint cellOrigin = CGPointMake(column * (itemSize.width + horizontalLayout.spacing),
                                                 row * (itemSize.height + verticalLayout.spacing));
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

- (MITAxisGridLayout)axisGridLayoutForWidth:(CGFloat)maxWidth
                                  itemWidth:(CGFloat)itemWidth
                           interItemSpacing:(CGFloat)spacing
{
    MITAxisGridLayout layout = MITAxisGridLayoutZero;
    
    CGFloat numberOfItems = (maxWidth + spacing) / (itemWidth + spacing);
    numberOfItems = floor(numberOfItems);
    
    CGFloat (^proposedWidth)(CGFloat,CGFloat,CGFloat) = ^(CGFloat numberOfItems, CGFloat itemWidth, CGFloat spacing) {
        return (numberOfItems * (itemWidth + spacing)) - spacing;
    };
    
    CGFloat currentWidth = proposedWidth(numberOfItems, itemWidth, spacing);
    CGFloat actualSpacing = spacing;
    
    BOOL stop = NO;
    while (!stop) {
        CGFloat nextWidth = proposedWidth(numberOfItems + 1, itemWidth, actualSpacing);
        
        if ((maxWidth - currentWidth ) < 0) {
            --numberOfItems;
            nextWidth = currentWidth;
            currentWidth = proposedWidth(numberOfItems, itemWidth, actualSpacing);
        } else if ((nextWidth - maxWidth) > 1.) {
            layout.numberOfItems = (NSUInteger)(floor(numberOfItems));
            stop = YES;
        } else {
            currentWidth = nextWidth;
            ++numberOfItems;
        }
    }
    
    stop = NO;
    currentWidth = proposedWidth(numberOfItems, itemWidth, actualSpacing);
    while (!stop) {
        CGFloat nextWidth = proposedWidth(numberOfItems, itemWidth, actualSpacing + 1);
        
        if ((maxWidth - nextWidth) < 1) {
            layout.spacing = floor(actualSpacing);
            stop = YES;
        } else {
            actualSpacing += (spacing / numberOfItems);
        }
        
        currentWidth = nextWidth;
    }
    
    return layout;
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
    UIScrollView *scrollView = self.collectionView;
    UICollectionViewLayoutAttributes *headerAttributes = _cachedLayoutAttributes[MITCollectionKindSectionHeader];
    if (headerAttributes) {
        headerAttributes.transform = CGAffineTransformMakeTranslation(scrollView.bounds.origin.x, 0);
    }
    
    UICollectionViewLayoutAttributes *footerAttributes = _cachedLayoutAttributes[MITCollectionKindSectionFooter];
    if (footerAttributes) {
        footerAttributes.transform = CGAffineTransformMakeTranslation(scrollView.bounds.origin.x, 0);
    }
    
    return YES;
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
