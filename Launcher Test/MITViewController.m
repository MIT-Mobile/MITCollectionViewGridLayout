//
//  MITViewController.m
//  Launcher Test
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import "MITViewController.h"
#import "MITCollectionViewGridLayout.h"

@interface MITViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) NSArray *content;
@end

@implementation MITViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    
    MITCollectionViewGridLayout *gridLayout = (MITCollectionViewGridLayout*)self.collectionView.collectionViewLayout;
    gridLayout.minimumInterItemSpacingX = 10.;
    gridLayout.minimumInterItemSpacingY = 10.;
    gridLayout.referenceHeaderHeight = 48.;
    gridLayout.referenceFooterHeight = 48.;
    
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"ModuleCell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindSectionFooter
                   withReuseIdentifier:@"FooterView"];

    
    NSMutableArray *viewContent = [[NSMutableArray alloc] init];
    NSUInteger colorDelta = 16;
    
    for (int i = 0; i < (colorDelta * 3); ++i) {
        CGFloat channel = 1. / ((i % colorDelta) + 1.);
        
        switch ((i / colorDelta) % 3) {
            case 0:
                [viewContent addObject:[UIColor colorWithRed:channel
                                                       green:0
                                                        blue:0
                                                       alpha:1]];
                break;
                
            case 1:
                [viewContent addObject:[UIColor colorWithRed:0
                                                       green:channel
                                                        blue:0
                                                       alpha:1]];
                break;
                
            case 2:
                [viewContent addObject:[UIColor colorWithRed:0
                                                       green:0
                                                        blue:channel
                                                       alpha:1]];
                break;
        }
    }
    
    self.content = viewContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([kind isEqualToString:MITCollectionKindSectionHeader]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                               withReuseIdentifier:@"HeaderView"
                                                                      forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor purpleColor];
    } else if ([kind isEqualToString:MITCollectionKindSectionFooter]) {
        reusableView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                               withReuseIdentifier:@"FooterView"
                                                                      forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor orangeColor];
    }
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320,48);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(320,48);;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(64, 72);
}
@end
