//
//  ZLTableViewCell.h
//  ZLForm_Example
//
//  Created by admin on 2026/5/26.
//  Copyright © 2026 fanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZLForm/ZLForm-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLTableViewCell : UITableViewCell <ZLFormDescriptorCell>
@property (nonatomic, strong) ZLFormRowDescriptor *rowDescriptor;
@end

NS_ASSUME_NONNULL_END