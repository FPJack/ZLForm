//
//  ZLFormSectionDescriptor.m
//  ZLForm
//
//  Created by admin on 2026/5/15.
//

#import "ZLFormSectionDescriptor.h"
#import "ZLFormDescriptor.h"
#import "ZLFormRowDescriptor.h"

@interface ZLFormSectionDescriptor ()
@property (nonatomic, strong,readwrite) NSMutableArray<ZLFormRowDescriptor *> *formRows;
@end
@implementation ZLFormSectionDescriptor
- (NSMutableArray *)formRows {
    if (!_formRows) {
        _formRows = [NSMutableArray array];
    }
    return _formRows;
}
-(instancetype)initWithTag:(NSString *)tag  {
    self = [super init];
    if (self) {
        self.tag = tag;
    }
    return self;
}

-(void)addFormRow:(nonnull ZLFormRowDescriptor *)formRow{
    if (![self.formRows containsObject:formRow]){
        formRow.sectionDescriptor = self;
        [self.formRows addObject:formRow];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRow:(ZLFormRowDescriptor *)afterRow {
   NSInteger index = [self.formRows indexOfObject:afterRow];
    if (index != NSNotFound) {
        formRow.sectionDescriptor = self;
        [self.formRows insertObject:formRow atIndex:index + 1];
    }
}

-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRow:(ZLFormRowDescriptor *)beforeRow {
    NSInteger index = [self.formRows indexOfObject:beforeRow];
    if (index != NSNotFound) {
        formRow.sectionDescriptor = self;
        [self.formRows insertObject:formRow atIndex:index];
    }
}

-(void)removeFormRow:(ZLFormRowDescriptor *)formRow {
    [self.formRows removeObject:formRow];
}

-(void)removeFormRowWithTag:(NSString *)tag {
    ZLFormRowDescriptor *rowDescriptor = [self formRowWithTag:tag];
    if (rowDescriptor) {
        [self removeFormRow:rowDescriptor];
    }
}
- (ZLFormRowDescriptor *)formRowWithTag:(NSString *)tag {
    ZLFormRowDescriptor *rowDescriptor = nil;
    for (ZLFormRowDescriptor *row in self.formRows) {
        if ([row.tag isEqualToString:tag]) {
            rowDescriptor = row;
            break;
        }
    }
    return rowDescriptor;
}
@end
