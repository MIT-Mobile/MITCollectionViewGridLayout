#import "MITCollectionViewDataSource.h"
#import "MITCollectionViewGridLayout.h"

@implementation MITCollectionViewDataSource
{
    NSUInteger _numberOfSections;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *viewContent = [[NSMutableArray alloc] init];
        NSUInteger colorDelta = 32;
        _numberOfSections = 3;
        
        for (NSUInteger i = 0; i < colorDelta; ++i) {
            CGFloat channelValue = ((CGFloat)(i % colorDelta) / (CGFloat)colorDelta);
            
            [viewContent addObject:[UIColor colorWithRed:channelValue
                                                   green:0
                                                    blue:0
                                                   alpha:1]];

            [viewContent addObject:[UIColor colorWithRed:0
                                                   green:channelValue
                                                    blue:0
                                                   alpha:1]];

            [viewContent addObject:[UIColor colorWithRed:0
                                                   green:0
                                                    blue:channelValue
                                                   alpha:1]];
        }
        
        self.content = viewContent;
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.content count] / _numberOfSections;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ModuleCell"
                                                                           forIndexPath:indexPath];
    
    cell.backgroundColor = self.content[(_numberOfSections * indexPath.item) + indexPath.section];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _numberOfSections;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:MITCollectionKindFloatingHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"HeaderView"
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor purpleColor];
    } else if ([kind isEqualToString:MITCollectionKindFloatingFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"FooterView"
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor orangeColor];
    }
    
    return reusableView;
}
@end
