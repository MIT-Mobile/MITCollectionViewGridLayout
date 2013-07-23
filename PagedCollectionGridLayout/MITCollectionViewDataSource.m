//
//  MITCollectionViewDataSource.m
//  PagedCollectionGridLayout
//
//  Created by Blake Skinner on 2013/07/22.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import "MITCollectionViewDataSource.h"
#import "MITCollectionViewGridLayout.h"

@implementation MITCollectionViewDataSource

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *viewContent = [[NSMutableArray alloc] init];
        NSUInteger colorDelta = 32;
        
        for (NSUInteger i = 0; i < (colorDelta * 3); ++i) {
            CGFloat channelValue = ((CGFloat)(i % colorDelta) / (CGFloat)colorDelta);
            NSUInteger channel = (i / colorDelta) % 3;
            
            switch (channel) {
                case 0:
                    [viewContent addObject:[UIColor colorWithRed:channelValue
                                                           green:0
                                                            blue:0
                                                           alpha:1]];
                    break;
                    
                case 1:
                    [viewContent addObject:[UIColor colorWithRed:0
                                                           green:channelValue
                                                            blue:0
                                                           alpha:1]];
                    break;
                    
                case 2:
                    [viewContent addObject:[UIColor colorWithRed:0
                                                           green:0
                                                            blue:channelValue
                                                           alpha:1]];
                    break;
            }
        }
        
        self.content = viewContent;
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.content count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ModuleCell"
                                                                           forIndexPath:indexPath];
    cell.backgroundColor = self.content[indexPath.item];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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
