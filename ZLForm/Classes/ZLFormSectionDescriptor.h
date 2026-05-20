//
//  ZLFormSectionDescriptor.h
//  ZLForm
//
//  Created by admin on 2026/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ZLFormDescriptor,ZLFormSectionDescriptor;
@class ZLFormRowDescriptor;

typedef UIView* _Nullable (^ZLFormSectionHeaderFooterViewBlock)(ZLFormSectionDescriptor *sectionDescriptor);

@interface ZLFormSectionDescriptor : NSObject

@property (nonatomic, assign)CGFloat headerHeight;
@property (nonatomic, copy)ZLFormSectionHeaderFooterViewBlock headerViewBlock;

@property (nonatomic, assign)CGFloat footerHeight;
@property (nonatomic, copy)ZLFormSectionHeaderFooterViewBlock footerViewBlock;

///添加动画
@property(nonatomic,assign)UITableViewRowAnimation insertAnimation;
///删除动画
@property(nonatomic,assign)UITableViewRowAnimation deleteAnimation;

@property (nonatomic, weak) ZLFormDescriptor * formDescriptor;

@property (nonatomic, strong,readonly) NSMutableArray<ZLFormRowDescriptor *> *formRows;

@property (nonatomic, copy) NSString * tag;

-(instancetype)initWithTag:(NSString *)tag ;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRow:(ZLFormRowDescriptor *)afterRow;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRow:(ZLFormRowDescriptor *)beforeRow;

-(void)removeFormRow:(ZLFormRowDescriptor *)formRow;

-(void)removeFormRowWithTag:(NSString *)tag;

///根据tag获取formRow
- (ZLFormRowDescriptor *)formRowWithTag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
