//
//  ZLFormRowDescriptor.h
//  ZLForm
//
//  Created by admin on 2026/5/15.
//

#import <Foundation/Foundation.h>
#import "ZLFormBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@class ZLFormSectionDescriptor,
ZLFormBaseCell,
ZLFormRowDescriptor,
ZLFormValidationStatus,
ZLFormValidator;

typedef void(^ZLOnChangeBlock)(id __nullable oldValue, id __nullable newValue, ZLFormRowDescriptor * __nonnull rowDescriptor);
typedef void(^ZLConfigureCellBlock)(UITableViewCell *cell, id value, ZLFormRowDescriptor * __nonnull rowDescriptor);
typedef void(^ZLUpdateCellBlock)(UITableViewCell *cell, id value, ZLFormRowDescriptor * __nonnull rowDescriptor);

@interface ZLFormRowDescriptor : NSObject

@property (nonatomic,strong)Class cellClass;

@property (nonatomic, strong,readonly) UITableViewCell<ZLFormDescriptorCell> *cell;

@property (nonatomic,assign)CGFloat height;

@property (nonatomic,copy)NSString * tag;

@property (nonatomic,copy)NSString * key;

@property (nonatomic,copy)NSString * title;

@property (nonatomic,strong)id value;

@property (nonatomic,weak) ZLFormSectionDescriptor * sectionDescriptor;

@property (nonatomic,copy) ZLOnChangeBlock onChangeBlock;

@property (nonatomic,copy)ZLConfigureCellBlock configureCellBlock;

@property (nonatomic,copy)ZLUpdateCellBlock updateCellBlock;

///添加动画
@property(nonatomic,assign)UITableViewRowAnimation insertAnimation;
///删除动画
@property(nonatomic,assign)UITableViewRowAnimation deleteAnimation;

@property (nonatomic,assign)BOOL disabled;

///获取表单值的时候忽略这一行
@property (nonatomic,assign)BOOL ignoreValue;


///value 映射成需要展示的值
@property (nonatomic,copy)id (^valueMapperToDisplay)(id value);

///展示的值映射成需要保存的值
@property (nonatomic,copy)id (^storageValueMapper)(id value);

- (id)valueForDisplay;

- (id)valueForStorage;

@property (nonatomic,copy) id emptyDisplayValue;

+(instancetype)formRowDescriptorWithTag:(NSString *)tag;

-(instancetype)initWithTag:(NSString *)tag ;

-(ZLFormBaseCell *)cellForFormController:(UIViewController *)formController;

///添加验证器
- (void)addValidator:(ZLFormValidator *)validator;

///移除验证器
- (void)removeValidator:(ZLFormValidator *)validator;

///添加验证器
- (void)addValidator:(NSString *)msg validationBlock:(BOOL (^)(id value))validationBlock;

///进行验证
-(ZLFormValidationStatus *)doValidation;
@end

NS_ASSUME_NONNULL_END
