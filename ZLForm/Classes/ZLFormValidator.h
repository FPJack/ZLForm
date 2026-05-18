//
//  ZLFormValidator.h
//  ZLForm
//
//  Created by admin on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ZLFormRowDescriptor,ZLFormValidationStatus;
@interface ZLFormValidator : NSObject
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) BOOL (^validationBlock)(id value);

- (instancetype)initWithMsg:(NSString *)msg validationBlock:(BOOL (^)(id value))validationBlock;

- (ZLFormValidationStatus *)validate:(ZLFormRowDescriptor *)rowDescriptor;
@end


@interface ZLFormValidationStatus : NSObject
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, weak) ZLFormRowDescriptor *rowDescriptor;
+(ZLFormValidationStatus *)formValidationStatusWithMsg:(NSString *)msg status:(BOOL)status rowDescriptor:(ZLFormRowDescriptor *)row;
@end

NS_ASSUME_NONNULL_END
