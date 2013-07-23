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
    gridLayout.referenceItemSize = CGSizeMake(64., 64.);
    
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"ModuleCell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindFloatingHeader
                   withReuseIdentifier:@"HeaderView"];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:MITCollectionKindFloatingFooter
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
