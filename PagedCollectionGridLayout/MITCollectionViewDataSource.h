//
//  MITCollectionViewDataSource.h
//  PagedCollectionGridLayout
//
//  Created by Blake Skinner on 2013/07/22.
//  Copyright (c) 2013 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MITCollectionViewDataSource : NSObject <UICollectionViewDataSource>
@property (nonatomic,strong) NSArray *content;

@end
