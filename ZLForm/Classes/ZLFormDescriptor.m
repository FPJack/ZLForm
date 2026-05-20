//
//  ZLFormDescriptor.m
//  ZLForm
//
//  Created by admin on 2026/5/14.
//

#import "ZLFormDescriptor.h"
#import "ZLFormSectionDescriptor.h"
#import "ZLFormRowDescriptor.h"
#import "ZLFormBaseCell.h"
#import "ZLFormValidator.h"
NSString * const ZLFormSectionsKey = @"formSections";

@interface ZLFormDescriptor ()

@property (nonatomic, strong,readwrite) NSMutableArray<ZLFormSectionDescriptor *> *formSections;

@end

@implementation ZLFormDescriptor
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self
               forKeyPath:ZLFormSectionsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:0];
    }
    return self;
}
- (NSMutableArray<ZLFormSectionDescriptor *> *)formSections {
    if (!_formSections) {
        _formSections = [NSMutableArray array];
    }
    return _formSections;
}
+(nonnull instancetype)formDescriptor {
    return [[self alloc] init];
}

-(void)addFormSection:(ZLFormSectionDescriptor *)formSection {
    if (![self.formSections containsObject:formSection]) {
        formSection.formDescriptor = self;
        [self insertObject:formSection inFormSectionsAtIndex:self.formSections.count];
    }
}
-(void)addFormSection:(ZLFormSectionDescriptor *)formSection afterSection:(ZLFormSectionDescriptor *)afterSection {
    NSInteger index = [self.formSections indexOfObject:afterSection];
    if (index != NSNotFound) {
        formSection.formDescriptor = self;
        [self insertObject:formSection inFormSectionsAtIndex:index + 1];
    }
}

-(void)addFormSection:(ZLFormSectionDescriptor *)formSection beforeSection:(ZLFormSectionDescriptor *)afterSection {
    NSInteger index = [self.formSections indexOfObject:afterSection];
    if (index != NSNotFound) {
        formSection.formDescriptor = self;
        [self insertObject:formSection inFormSectionsAtIndex:index];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRow:(ZLFormRowDescriptor *)afterRow {
    ZLFormSectionDescriptor *section = afterRow.sectionDescriptor;
    if (section) {
        [section addFormRow:formRow beforeRow:afterRow];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRowTag:( NSString *)beforeRowTag {
    ZLFormSectionDescriptor *section = [self formRowWithTag:beforeRowTag].sectionDescriptor;
    if (section) {
        [section addFormRow:formRow beforeRow:[section formRowWithTag:beforeRowTag]];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRow:(ZLFormRowDescriptor *)afterRow {
    ZLFormSectionDescriptor *section = afterRow.sectionDescriptor;
    if (section) {
        [section addFormRow:formRow afterRow:afterRow];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag {
    ZLFormSectionDescriptor *section = [self formRowWithTag:afterRowTag].sectionDescriptor;
    if (section) {
        [section addFormRow:formRow afterRow:[section formRowWithTag:afterRowTag]];
    }
}
-(void)removeFormSectionAtIndex:(NSUInteger)index {
    if (index < self.formSections.count) {
        [self removeObjectFromFormSectionsAtIndex:index];
    }
}
-(void)removeFormSection:(ZLFormSectionDescriptor *)formSection {
    NSInteger index = [self.formSections indexOfObject:formSection];
    if (index != NSNotFound) {
        [self removeObjectFromFormSectionsAtIndex:index];
    }
}
-(void)removeFormRow:(ZLFormRowDescriptor *)formRow {
    ZLFormSectionDescriptor *section = formRow.sectionDescriptor;
    if (section) {
        [section removeFormRow:formRow];
    }
}
-(void)removeFormRowWithTag:(NSString *)tag {
    ZLFormRowDescriptor *row = [self formRowWithTag:tag];
    ZLFormSectionDescriptor *section = row.sectionDescriptor;
    if (section && row) {
        [section removeFormRow:row];
    }
}
-(ZLFormRowDescriptor *)formRowWithTag:(NSString *)tag {
    ZLFormRowDescriptor *row = nil;
    for (ZLFormSectionDescriptor *s in self.formSections) {
        row = [s formRowWithTag:tag];
        if (row) {
            break;
        }
    }
    return row;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.formSections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    return sectionDescriptor.formRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    ZLFormBaseCell *cell = rowDescriptor.cell;
    if (rowDescriptor.updateCellBlock) {
        rowDescriptor.updateCellBlock(cell, rowDescriptor.value, rowDescriptor);
    }
    id<ZLFormDescriptorCell> formCell = (id<ZLFormDescriptorCell>)cell;
    [formCell update];
    
    if ([self.delegate respondsToSelector:@selector(formDescriptor:updateFormRow:)]) {
        [self.delegate formDescriptor:self updateFormRow:rowDescriptor];
    }
    
    cell.titleLabel.text = rowDescriptor.title;
    cell.detailLabel.text = rowDescriptor.valueForDisplay;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    return rowDescriptor.height > 0 ? rowDescriptor.height : 44.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    return sectionDescriptor.headerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    if (sectionDescriptor.headerViewBlock) {
        return sectionDescriptor.headerViewBlock(sectionDescriptor);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    return sectionDescriptor.footerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    if (sectionDescriptor.footerViewBlock) {
        return sectionDescriptor.footerViewBlock(sectionDescriptor);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[section];
    return sectionDescriptor.tag;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(formDescriptor:didSelectFormRow:)]) {
        [self.delegate formDescriptor:self didSelectFormRow:rowDescriptor];
        
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(formDescriptor:deselectFormRow:)]) {
        [self.delegate formDescriptor:self deselectFormRow:rowDescriptor];
    }
}
- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}
-(NSIndexPath *)indexPathOfFormRow:(ZLFormRowDescriptor *)formRow
{
    NSIndexPath *result = nil;
    ZLFormSectionDescriptor *section = formRow.sectionDescriptor;
    if (section) {
        NSUInteger sectionIndex = [self.formSections indexOfObject:section];
        if (sectionIndex != NSNotFound) {
            NSUInteger rowIndex = [section.formRows indexOfObject:formRow];
            if (rowIndex != NSNotFound) {
                result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    return result;
}
-(void)reloadFormRow:(ZLFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)reloadFormSection:(ZLFormSectionDescriptor *)formSection {
    NSInteger section = [self.formSections indexOfObject:formSection];
    if (section == NSNotFound) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
        [self.tableView reloadSections:set
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(NSDictionary *)formValues
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (ZLFormSectionDescriptor *section in self.formSections) {
        for (ZLFormRowDescriptor *row in section.formRows) {
            if (!row.ignoreValue) {
                id value = [row valueForStorage];
                NSString *key = row.key ?: row.tag;
                if (key.length > 0 && value != nil) {
                    [result setValue:value forKey:key];
                }
            }
        }
    }
    return result;
}
-(NSArray<ZLFormValidationStatus *> *)formValidationErrors{
    NSMutableArray *result = [NSMutableArray array];
    for (ZLFormSectionDescriptor *section in self.formSections) {
        for (ZLFormRowDescriptor *row in section.formRows) {
            if (row.ignoreValue) continue;
            ZLFormValidationStatus *status = [row doValidation];
            if (status != nil && (![status isValid])) {
                [result addObject:status];
            }
        }
    }
    return result;
}
-(void )validation {
    BOOL hasError = NO;
    for (ZLFormSectionDescriptor *section in self.formSections) {
        for (ZLFormRowDescriptor *row in section.formRows) {
            if (row.ignoreValue) continue;
            ZLFormValidationStatus *status = [row doValidation];
            if (status != nil && (![status isValid])) {
                hasError = YES;
                if ([self.delegate respondsToSelector:@selector(formDescriptor:showFormValidationError:)]) {
                    [self.delegate formDescriptor:self showFormValidationError:status];
                }
                break;
            }
        }
    }
    if (!hasError) {
        if ([self.delegate respondsToSelector:@selector(validationSuccessForFormDescriptor:)]) {
            [self.delegate validationSuccessForFormDescriptor:self];
        }
    }
}

-(void )validationAll {
    NSArray *errors = [self formValidationErrors];
    if (errors.count > 0 && [self.delegate respondsToSelector:@selector(formDescriptor:showFormValidationErrors:)]) {
        [self.delegate formDescriptor:self showFormValidationErrors:errors];
    }
    else if (errors.count == 0 && [self.delegate respondsToSelector:@selector(validationSuccessForFormDescriptor:)]) {
        [self.delegate validationSuccessForFormDescriptor:self];
    }
}

#pragma mark - KVC

-(NSUInteger)countOfFormSections
{
    return self.formSections.count;
}

- (id)objectInFormSectionsAtIndex:(NSUInteger)index
{
    return [self.formSections objectAtIndex:index];
}

- (NSArray *)formSectionsAtIndexes:(NSIndexSet *)indexes
{
    return [self.formSections objectsAtIndexes:indexes];
}

- (void)insertObject:(ZLFormSectionDescriptor *)formSection inFormSectionsAtIndex:(NSUInteger)index
{
    [self.formSections insertObject:formSection atIndex:index];
}

- (void)removeObjectFromFormSectionsAtIndex:(NSUInteger)index
{
    [self.formSections removeObjectAtIndex:index];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
    
     if ([keyPath isEqualToString:ZLFormSectionsKey]) {
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            ZLFormSectionDescriptor *section = [self.formSections objectAtIndex:indexSet.firstIndex];
            [self formSectionHasBeenAdded:section atIndex:indexSet.firstIndex];
        }
        else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]) {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            ZLFormSectionDescriptor *removedSection = [[change objectForKey:NSKeyValueChangeOldKey] objectAtIndex:0];
            [self formSectionHasBeenRemoved:removedSection atIndex:indexSet.firstIndex];

        }
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:ZLFormSectionsKey];
    [_formSections removeAllObjects];
    _formSections = nil;
}


-(void)formSectionHasBeenRemoved:(ZLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index {
    
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:formSection.deleteAnimation];
    [self.tableView endUpdates];
    if ([self.delegate respondsToSelector:@selector(formDescriptor:formSectionHasBeenRemoved:atIndex:)]) {
        [self.delegate formDescriptor:self formSectionHasBeenRemoved:formSection atIndex:index];
    }
}
-(void)formSectionHasBeenAdded:(ZLFormSectionDescriptor *)formSection atIndex:(NSUInteger)index {
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:formSection.insertAnimation];
    [self.tableView endUpdates];
    if ([self.delegate respondsToSelector:@selector(formDescriptor:formSectionHasBeenAdded:atIndex:)]) {
        [self.delegate formDescriptor:self formSectionHasBeenAdded:formSection atIndex:index];
    }
}
@end
