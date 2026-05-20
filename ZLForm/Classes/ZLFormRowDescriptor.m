//
//  ZLFormRowDescriptor.m
//  ZLForm
//
//  Created by admin on 2026/5/15.
//

#import "ZLFormRowDescriptor.h"
#import "ZLFormSectionDescriptor.h"
#import "ZLFormBaseCell.h"
#import "ZLFormValidator.h"

@interface ZLFormRowDescriptor ()
@property (nonatomic, strong,readwrite) ZLFormBaseCell *cell;
@property (nonatomic, strong) NSMutableArray<ZLFormValidator *> *validators;
@end
@implementation ZLFormRowDescriptor
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.configureCellBlock = ^(UITableViewCell * _Nonnull cell, id  _Nonnull value, ZLFormRowDescriptor * _Nonnull rowDescriptor) {
            
        };
        self.updateCellBlock = ^(UITableViewCell * _Nonnull cell, id  _Nonnull value, ZLFormRowDescriptor * _Nonnull rowDescriptor) {
            
        };
        [self addObserver:self
               forKeyPath:@"value"
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    }
    return self;
}
- (NSMutableArray *)validators {
    if (!_validators) {
        _validators = [NSMutableArray array];
    }
    return _validators;
}
+(instancetype)formRowDescriptorWithTag:(NSString *)tag {
    return [[self alloc] initWithTag:tag];
}
- (ZLFormBaseCell *)cell {
    if (!_cell) {
        _cell = [self createCell];
        _cell.rowDescriptor = self;
    }
    return _cell;
}
- (ZLFormBaseCell *)createCell {
    if (self.cellClass) {
        return [[self.cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.tag];
    }else {
        return [[ZLFormBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.tag];
    }
}
- (CGFloat)height {
    CGFloat height = _height;
    if (self.cell) {
        if ([self.cell conformsToProtocol:@protocol(ZLFormDescriptorCell)]) {
            if ([self.cell respondsToSelector:@selector(cellHeightForRowDescriptor:)]) {
                height = [(id<ZLFormDescriptorCell>)self.cell cellHeightForRowDescriptor:self];
            }
        }
    }
    return height > 0 ? height : 44.0;
}

-(instancetype)initWithTag:(NSString *)tag  {
    self = [self init];
    if (self) {
        self.tag = tag;
    }
    return self;
}
-(UITableViewCell<ZLFormDescriptorCell> *)cellForFormController:(UIViewController *)formController {
    return self.cell;
}

- (id )valueForDisplay {
    if (self.valueMapperToDisplay) {
        return  self.valueMapperToDisplay(self.value);
    }
    return self.value;
}
- (id )valueForStorage {
    if (self.storageValueMapper) {
        return self.storageValueMapper(self.value);
    }
    return self.value;
}
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.sectionDescriptor) return;
    if (object == self && [keyPath isEqualToString:@"value"]) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        if ([keyPath isEqualToString:@"value"]) {
            if (self.onChangeBlock) {
                self.onChangeBlock(oldValue, newValue, self);
            }
        }
    }
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"value"];
}

- (void)addValidator:(ZLFormValidator *)validator{
    if (validator) {
        [self.validators addObject:validator];
    }
}
- (void)removeValidator:(ZLFormValidator *)validator {
    if (validator) {
        [self.validators removeObject:validator];
    }
}
- (void)addValidator:(NSString *)msg validationBlock:(BOOL (^)(id value))validationBlock {
    ZLFormValidator *validator = [[ZLFormValidator alloc] initWithMsg:msg validationBlock:validationBlock];
    [self addValidator:validator];
}
- (ZLFormValidationStatus *)doValidation {
    for (ZLFormValidator *validator in self.validators) {
        ZLFormValidationStatus *status = [validator validate:self];
        if (!status.isValid) {
            return status;
        }
    }
    return [ZLFormValidationStatus formValidationStatusWithMsg:@"" status:YES rowDescriptor:self];
}
@end
