//
//  ZLFormBaseCell.h
//  ZLForm
//
//  Created by admin on 2026/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ZLFormRowDescriptor;

@protocol ZLFormDescriptorCell <NSObject>

@required
@property (nonatomic, weak) ZLFormRowDescriptor * rowDescriptor;
-(void)configure;
-(void)update;
@optional

-(CGFloat)cellHeightForRowDescriptor:(ZLFormRowDescriptor *)rowDescriptor;
-(void)formDescriptorCellDidSelectedWithFormController:(UIViewController *)controller;
@end


@interface ZLFormBaseCell : UITableViewCell<ZLFormDescriptorCell>
@property (nonatomic, weak) ZLFormRowDescriptor * rowDescriptor;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;
@end

NS_ASSUME_NONNULL_END
