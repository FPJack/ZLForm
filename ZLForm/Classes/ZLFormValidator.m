//
//  ZLFormValidator.m
//  ZLForm
//
//  Created by admin on 2026/5/18.
//

#import "ZLFormValidator.h"
#import "ZLFormRowDescriptor.h"

@implementation ZLFormValidator
- (instancetype)initWithMsg:(NSString *)msg validationBlock:(BOOL (^)(id value))validationBlock{
    self = [super init];
    if (self) {
        self.msg = msg;
        self.validationBlock = validationBlock;
    }
    return self;
}
- (ZLFormValidationStatus *)validate:(ZLFormRowDescriptor *)rowDescriptor{
    BOOL isValid = NO;
    if (rowDescriptor.required) {
        if (self.validationBlock) {
             isValid = self.validationBlock(rowDescriptor.value);
        }
    }else {
        isValid = YES;
    }
    ZLFormValidationStatus *status = [ZLFormValidationStatus formValidationStatusWithMsg:self.msg status:isValid rowDescriptor:rowDescriptor];
    return status;
}
@end
@implementation ZLFormValidationStatus
-(instancetype)initWithMsg:(NSString*)msg status:(BOOL)isValid rowDescriptor:(ZLFormRowDescriptor *)row {
    self = [super init];
    if (self) {
        self.msg = msg;
        self.isValid = isValid;
        self.rowDescriptor = row;
    }
    return self;
}
+(ZLFormValidationStatus *)formValidationStatusWithMsg:(NSString *)msg status:(BOOL)status rowDescriptor:(ZLFormRowDescriptor *)row {
    return [[self alloc] initWithMsg:msg status:status rowDescriptor:row];
}
@end
