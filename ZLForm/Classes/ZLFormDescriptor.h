//
//  ZLFormDescriptor.h
//  ZLForm
//
//  Created by admin on 2026/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ZLFormSectionDescriptor;
@class ZLFormBaseCell;
@class ZLFormRowDescriptor;
@class ZLFormDescriptor;
@class ZLFormValidationStatus;

@protocol ZLFormDescriptorDelegate <NSObject>

@optional

-(void)formDescriptor:(ZLFormDescriptor *)form didSelectFormRow:(ZLFormRowDescriptor *)formRow;

-(void)formDescriptor:(ZLFormDescriptor *)form deselectFormRow:(ZLFormRowDescriptor *)formRow;

-(void)formDescriptor:(ZLFormDescriptor *)form updateFormRow:(ZLFormRowDescriptor *)formRow;


-(void)formDescriptor:(ZLFormDescriptor *)form showFormValidationError:(ZLFormValidationStatus *)status;

///校验通过 不带status
- (void)validationSuccessForFormDescriptor:(ZLFormDescriptor *)form;

-(void)formDescriptor:(ZLFormDescriptor *)form showFormValidationErrors:(NSArray<ZLFormValidationStatus *> *)status;
///所有校验通过 不带status
- (void)validationAllSuccessForFormDescriptor:(ZLFormDescriptor *)form;

-(void)formDescriptor:(ZLFormDescriptor *)form formSectionHasBeenRemoved:(ZLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index;

-(void)formDescriptor:(ZLFormDescriptor *)form formSectionHasBeenAdded:(ZLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index;

-(void)formDescriptor:(ZLFormDescriptor *)form formRowHasBeenAdded:(ZLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath;

-(void)formDescriptor:(ZLFormDescriptor *)form formRowHasBeenRemoved:(ZLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath;

@end




@interface ZLFormDescriptor : NSObject<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong,readonly) NSMutableArray<ZLFormSectionDescriptor *> *formSections;

@property (nonatomic, weak) id<ZLFormDescriptorDelegate> delegate;

@property (nonatomic, weak)UITableView *tableView;

+(nonnull instancetype)formDescriptor;

-(void)addFormSection:(ZLFormSectionDescriptor *)formSection;

-(void)addFormSection:(ZLFormSectionDescriptor *)formSection afterSection:(ZLFormSectionDescriptor *)afterSection;

-(void)addFormSection:(ZLFormSectionDescriptor *)formSection beforeSection:(ZLFormSectionDescriptor *)afterSection;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRow:(ZLFormRowDescriptor *)afterRow;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRowTag:( NSString *)beforeRowTag;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRow:(ZLFormRowDescriptor *)afterRow;

-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag;

-(void)removeFormSectionAtIndex:(NSUInteger)index;

-(void)removeFormSection:(ZLFormSectionDescriptor *)formSection;

-(void)removeFormRow:(ZLFormRowDescriptor *)formRow;

-(void)removeFormRowWithTag:(NSString *)tag;

-(ZLFormRowDescriptor *)formRowWithTag:(NSString *)tag;


///刷新某一列
-(void)reloadFormRow:(ZLFormRowDescriptor *)formRow;
///刷新某一组
- (void)reloadFormSection:(ZLFormSectionDescriptor *)formSection;

///根据formRow获取indexPath
-(NSIndexPath *)indexPathOfFormRow:(ZLFormRowDescriptor *)formRow;

///表单所有的value key = tag value = value
-(NSDictionary *)formValues;

/// 本地校验表单 返回所有校验不通过的校验状态对象
-(NSArray<ZLFormValidationStatus *> *)formValidationErrors;

///校验表单 只要有一个不通过就触发调用-(void)formDescriptor:(ZLFormDescriptor *)form showFormValidationError:(ZLFormValidationStatus *)status;
-(void )validation;

///校验表单 返回所有不通过的校验状态对象触发调用 -(void)formDescriptor:(ZLFormDescriptor *)form showFormValidationErrors:(NSArray<ZLFormValidationStatus *> *)status;
-(void )validationAll;

@end

NS_ASSUME_NONNULL_END
