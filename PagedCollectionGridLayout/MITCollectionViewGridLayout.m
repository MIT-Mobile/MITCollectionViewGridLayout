#import "MITCollectionViewGridLayout.h"

typedef struct {
    CGFloat spacing;
    NSUInteger numberOfItems;
} MITAxisGridLayout;

const MITAxisGridLayout MITAxisGridLayoutZero = {.spacing = 0., .numberOfItems = 0};

NSString* const MITCollectionKindFloatingHeader = @"MITCollectionKindFloatingHeader";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindFloatingFooter = @"MITCollectionKindFloatingFooter";  // @{<key> : UICollectionViewLayoutAttributes}
NSString* const MITCollectionKindCell = @"MITCollectionKindCell";                    // @{<key> : @{ NSIndexPath : UICollectionViewLayoutAttributes}}

NSString* const MITCollectionSectionIndexKey = @"MITCollectionSectionIndex";
NSString* const MITCollectionPageLayoutKey = @"MITCollectionPageLayout";

@interface NSIndexPath (MITCollectionViewGridLayout)
+ (NSIndexPath*)indexPathForPage:(NSInteger)page inSection:(NSInteger)section;
@end

/* Caching Scheme:
 *  @{  "MITCollectionKindCell"           : @{"NSIndexPath" : "UICollectionViewLayoutAttributes"},
 *      "MITCollectionKindFloatingHeader" : "UICollectionViewLayoutAttributes",
 *      "MITCollectionKindFloatingFooter" : "UICollectionViewLayoutAttributes"}]
 */
@implementation MITCollectionViewGridLayout
{
    CGSize _cachedCollectionViewContentSize;
    CGSize _cachedPageSize;
    
    NSMutableDictionary *_cachedLayoutAttributes;
    BOOL _layoutInvalidatedByFloatingViews;
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
    _referenceItemSize = CGSizeMake(64, 64);
    _referenceHeaderHeight = 0;
    _referenceFooterHeight = 0;
    
    _cachedCollectionViewContentSize = CGSizeZero;
    _cachedPageSize = CGSizeZero;
    _cachedLayoutAttributes = [[NSMutableDictionary alloc] init];
    _layoutInvalidatedByFloatingViews = NO;
}

- (void)prepareLayout
{
    
    _cachedPageSize = self.collectionView.bounds.size;
    
    // Always start laying out everything from the origin of the
    // scroll view. This allows us to move the headers around by
    // just adding a translation transform to the layout attributes.
    CGRect pageContentBounds = CGRectMake(0,
                                          0,
                                          _cachedPageSize.width,
                                          _cachedPageSize.height);
    
    if (_referenceHeaderHeight > 1.) {
        UICollectionViewLayoutAttributes *layoutAttributes = _cachedLayoutAttributes[MITCollectionKindFloatingHeader];
        
        // Looks like a new layout attributes object
        if (!layoutAttributes) {
            
            // Just to get a valid index path. Don't trust it.
            // The item index for the header is 0, the footer is 1
            // and the section is garbage.
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0
                                                               inSection:0];
            layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindFloatingHeader
                                                                                              withIndexPath:headerIndexPath];
            
            // Limit to 25% of the view height
            CGFloat headerHeight = MIN(_referenceHeaderHeight,_cachedPageSize.height / 4.);
            
            // Layout the frame relative to the origin of the first page
            // The offset to the current page will be handled later using
            // a transform
            CGRect frame = CGRectZero;
            frame.size = CGSizeMake(_cachedPageSize.width, headerHeight);
            layoutAttributes.frame = frame;
            
            // No special significance to this value, it just needs to be
            // high enough so that it floats above all reasonable values that
            // either the cells or any other supplementary views may have
            layoutAttributes.zIndex = 1024;
            
            // Adjust the contentBounds so we know where we can
            // put cells so that they won't be covered by the floating
            // views
            pageContentBounds.origin.y += headerHeight;
            pageContentBounds.size.height -= headerHeight;
            _cachedLayoutAttributes[MITCollectionKindFloatingHeader] = layoutAttributes;
        }
        
        // If we are called to re-layout our view, make sure we also re-adjust
        // the position of the header transform so the view appears to be sticking
        // to the viewport. The header's transform should be updated using the
        // current content offset from the scroll view (aka: our collection view).
        //  Remember contentOffset == bounds.origin!
        layoutAttributes.transform = CGAffineTransformMakeTranslation(CGRectGetMinX(self.collectionView.bounds), 0);
    } else {
        [_cachedLayoutAttributes removeObjectForKey:MITCollectionKindFloatingHeader];
    }
    
    
    // Almost verbatim to the header layout code above. The only difference is the
    // view is placed at the bottom of the page instead of at the top.
    if (_referenceFooterHeight > 1.) {
        UICollectionViewLayoutAttributes *layoutAttributes = _cachedLayoutAttributes[MITCollectionKindFloatingFooter];
        if (!layoutAttributes) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1
                                                         inSection:0];
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MITCollectionKindFloatingFooter
                                                                                                                                withIndexPath:indexPath];
            
            // Limit to 25% of the view
            CGFloat footerHeight = MIN(_referenceFooterHeight,_cachedPageSize.height / 4.);
            
            CGRect frame = CGRectZero;
            frame.size = CGSizeMake(_cachedPageSize.width, footerHeight);
            frame.origin.y = _cachedPageSize.height - footerHeight;
            layoutAttributes.frame = frame;
            layoutAttributes.zIndex = 1024;
            
            pageContentBounds.size.height -= footerHeight;
            _cachedLayoutAttributes[MITCollectionKindFloatingFooter] = layoutAttributes;
        }
        
        layoutAttributes.transform = CGAffineTransformMakeTranslation(CGRectGetMinX(self.collectionView.bounds), 0);
    } else {
        [_cachedLayoutAttributes removeObjectForKey:MITCollectionKindFloatingFooter];
    }
    
    
    // (bskinner - 2013.07.23)
    // TODO: Should this also need to verify the item count?

    // Layout the cells if needed. Right now, 'if needed' means if
    // the NSDictionary stored for the 'MITCollectionKindCell' key is
    // nil or empty.
    if ([_cachedLayoutAttributes[MITCollectionKindCell] count] == 0) {
        // Start from a blank slate!
        _cachedLayoutAttributes[MITCollectionKindCell] = [[NSMutableDictionary alloc] init];
        
        pageContentBounds = UIEdgeInsetsInsetRect(pageContentBounds, _contentInsets);
        
        // Make sure that the maximum item size we try to layout
        // is bounded to the current page bounds
        CGSize itemSize = CGSizeMake(MIN(_referenceItemSize.width,CGRectGetWidth(pageContentBounds)),
                                     MIN(_referenceItemSize.height,CGRectGetHeight(pageContentBounds)));
        
        // These two calls calculate the inter-item padding for both the
        // horizontal and vertical axis, and figures out how many items
        // can be fit in each axis. Since each cell is a fixed size, this is
        // pretty easy.
        //
        // This does have an issue where, if the spacing is
        // does not come out to a round number, there could be additional
        // padding on the right hand side of the page.
        MITAxisGridLayout horizontalLayout = [self layoutGridAxisWithLength:CGRectGetWidth(pageContentBounds)
                                                                itemLength:itemSize.width
                                                         interItemSpacing:_minimumInterItemSpacing.width];
        MITAxisGridLayout verticalLayout = [self layoutGridAxisWithLength:CGRectGetHeight(pageContentBounds)
                                                              itemLength:itemSize.height
                                                       interItemSpacing:_minimumInterItemSpacing.height];
        NSUInteger pageCount = 0;
        NSUInteger numberOfSections = [self.collectionView numberOfSections];
        
        for (NSUInteger section = 0; section < numberOfSections; ++section) {
            NSUInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            CGPoint pageFrameOrigin = CGPointZero;
            
            for (NSUInteger item = 0; item < numberOfItemsInSection; ++item) {
                NSUInteger column = item % horizontalLayout.numberOfItems;
                NSUInteger row = (item / horizontalLayout.numberOfItems) % verticalLayout.numberOfItems;
                
                // Create a new page once we either go beyond the bounds
                // of the current one, or this is our first loop through
                // a new section.
                if ((row == 0) && (column == 0)) {
                    
                    // Figure out where the frame should be positioned in the view.
                    // Each cell is layed out starting from the page's origin
                    // ((0,0) by default unless the contentInsets was changed) and then
                    // offset by the page's frame origin.
                    pageFrameOrigin.x = (pageCount * _cachedPageSize.width);
                    pageFrameOrigin.y = 0;
                    ++pageCount;
                }
                
                CGPoint cellOrigin = CGPointMake(column * (itemSize.width + horizontalLayout.spacing),
                                                 row * (itemSize.height + verticalLayout.spacing));
                cellOrigin.x += CGRectGetMinX(pageContentBounds) + pageFrameOrigin.x;
                cellOrigin.y += CGRectGetMinY(pageContentBounds) + pageFrameOrigin.y;

                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item
                                                             inSection:section];
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttributes.frame = (CGRect){.origin = cellOrigin, .size = itemSize };
                
                NSMutableDictionary *cellsLayoutAttributes = _cachedLayoutAttributes[MITCollectionKindCell];
                cellsLayoutAttributes[indexPath] = layoutAttributes;
            }
        }
        
        _cachedCollectionViewContentSize.height = _cachedPageSize.height;
        _cachedCollectionViewContentSize.width = _cachedPageSize.width + (MAX(pageCount - 1, 0) * _cachedPageSize.width);
    }
}

- (MITAxisGridLayout)layoutGridAxisWithLength:(CGFloat)maxLength
                                  itemLength:(CGFloat)itemLength
                           interItemSpacing:(CGFloat)spacing
{
    MITAxisGridLayout layout = MITAxisGridLayoutZero;
    
    CGFloat numberOfItems = floor((maxLength + spacing) / (itemLength + spacing));
    layout.numberOfItems = numberOfItems;
    
    if ((numberOfItems - 1.) > 0) {
        layout.spacing = floor((maxLength - (numberOfItems * itemLength)) / (numberOfItems - 1.));
    } else {
        layout.spacing = 0;
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
    if ([MITCollectionKindFloatingHeader isEqualToString:kind]) {
        return _cachedLayoutAttributes[MITCollectionKindFloatingHeader];
    } else if ([MITCollectionKindFloatingFooter isEqualToString:kind]) {
        return _cachedLayoutAttributes[MITCollectionKindFloatingFooter];
    } else {
        return nil;
    }
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributesInRect = [[NSMutableArray alloc] init];
    
    if (_cachedLayoutAttributes[MITCollectionKindFloatingHeader]) {
        [layoutAttributesInRect addObject:_cachedLayoutAttributes[MITCollectionKindFloatingHeader]];
    }
    
    if (_cachedLayoutAttributes[MITCollectionKindFloatingFooter]) {
        [layoutAttributesInRect addObject:_cachedLayoutAttributes[MITCollectionKindFloatingFooter]];
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
    // This is called on every bounds change to see if we need to fix anything
    // with the layout. In this case, we do need to tweak the positioning
    // of the floating views but since it's only horizontal movement,
    // we don't want to also relayout all the cells. This flag is a hint to
    // invalidateLayout about what cached objects need to be dumped
    _layoutInvalidatedByFloatingViews = YES;
    return YES;
}

- (void)invalidateLayout
{
    if (!_layoutInvalidatedByFloatingViews) {
        [_cachedLayoutAttributes removeAllObjects];
    } else {
        // If the layout invalidation was triggered by the floating views
        // needing to be repositioned,
        _layoutInvalidatedByFloatingViews = NO;
    }
    
    [super invalidateLayout];
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

@implementation NSIndexPath (MITCollectionViewGridLayout)
+ (NSIndexPath*)indexPathForPage:(NSInteger)page
                       inSection:(NSInteger)section
{
    NSUInteger indicies[] = {section,page};
    return [[NSIndexPath alloc] initWithIndexes:indicies
                                         length:2];
}

- (NSUInteger)page
{
    return [self indexAtPosition:1];
}

@end
