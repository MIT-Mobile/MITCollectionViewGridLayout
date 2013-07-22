//
//  MITViewController.m
//  Launcher Test
//
//  Created by Blake Skinner on 2013/07/15.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import "MITViewController.h"
#import "MITCollectionViewGridLayout.h"
#import "MITCollectionViewDataSource.h"

@interface MITViewController () <UICollectionViewDelegate>
@end

@implementation MITViewController
{
    MITCollectionViewDataSource *_dataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.alwaysBounceVertical = NO;
    
    MITCollectionViewGridLayout *gridLayout = (MITCollectionViewGridLayout*)self.collectionView.collectionViewLayout;
    gridLayout.minimumInterItemSpacing = CGSizeMake(8.,8.);
    gridLayout.referenceHeaderHeight = 48.;
    gridLayout.referenceFooterHeight = 48.;
    gridLayout.referenceItemSize = CGSizeMake(60., 90.);
    
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"ModuleCell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindSectionFooter
                   withReuseIdentifier:@"FooterView"];
    
    _dataSource = [[MITCollectionViewDataSource alloc] init];
    self.collectionView.dataSource = _dataSource;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
