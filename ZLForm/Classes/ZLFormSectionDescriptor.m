//
//  ZLFormSectionDescriptor.m
//  ZLForm
//
//  Created by admin on 2026/5/15.
//

#import "ZLFormSectionDescriptor.h"
#import "ZLFormDescriptor.h"
#import "ZLFormRowDescriptor.h"
NSString * const ZLFormRowsKey = @"formRows";

@interface ZLFormSectionDescriptor ()
@property (nonatomic, strong,readwrite) NSMutableArray<ZLFormRowDescriptor *> *formRows;
@end
@implementation ZLFormSectionDescriptor
-(instancetype)init
{
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:ZLFormRowsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:0];
    }
    
    return self;
}
- (NSMutableArray *)formRows {
    if (!_formRows) {
        _formRows = [NSMutableArray array];
    }
    return _formRows;
}
-(instancetype)initWithTag:(NSString *)tag  {
    self = [self init];
    if (self) {
        self.tag = tag;
    }
    return self;
}

-(void)addFormRow:(nonnull ZLFormRowDescriptor *)formRow{
    if (![self.formRows containsObject:formRow]){
        formRow.sectionDescriptor = self;
        [self insertObject:formRow inFormRowsAtIndex:self.formRows.count];
    }
}
-(void)addFormRow:(ZLFormRowDescriptor *)formRow afterRow:(ZLFormRowDescriptor *)afterRow {
   NSInteger index = [self.formRows indexOfObject:afterRow];
    if (index != NSNotFound) {
        formRow.sectionDescriptor = self;
        [self insertObject:formRow inFormRowsAtIndex:index + 1];
    }
}

-(void)addFormRow:(ZLFormRowDescriptor *)formRow beforeRow:(ZLFormRowDescriptor *)beforeRow {
    NSInteger index = [self.formRows indexOfObject:beforeRow];
    if (index != NSNotFound) {
        formRow.sectionDescriptor = self;
        [self insertObject:formRow inFormRowsAtIndex:index];
    }
}

-(void)removeFormRow:(ZLFormRowDescriptor *)formRow {
    NSInteger index = [self.formRows indexOfObject:formRow];
    if (index != NSNotFound) {
        [self removeObjectFromFormRowsAtIndex:index];
    }
    
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

#pragma mark - KVC

-(NSUInteger)countOfFormRows
{
    return self.formRows.count;
}

- (id)objectInFormRowsAtIndex:(NSUInteger)index
{
    return [self.formRows objectAtIndex:index];
}

- (NSArray *)formRowsAtIndexes:(NSIndexSet *)indexes
{
    return [self.formRows objectsAtIndexes:indexes];
}

- (void)insertObject:(ZLFormRowDescriptor *)formRow inFormRowsAtIndex:(NSUInteger)index
{
    formRow.sectionDescriptor = self;
    [self.formRows insertObject:formRow atIndex:index];
}

- (void)removeObjectFromFormRowsAtIndex:(NSUInteger)index
{
    [self.formRows removeObjectAtIndex:index];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
     if ([keyPath isEqualToString:ZLFormRowsKey]) {
        if ([self.formDescriptor.formSections containsObject:self]) {
            if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
                NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
                ZLFormRowDescriptor *formRow = [((ZLFormSectionDescriptor *)object).formRows objectAtIndex:indexSet.firstIndex];
                NSUInteger sectionIndex = [self.formDescriptor.formSections indexOfObject:object];
                [self formRowHasBeenAdded:formRow
                                                      atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
               
            }
            else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]) {
                NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
                ZLFormRowDescriptor *removedRow = [[change objectForKey:NSKeyValueChangeOldKey] objectAtIndex:0];
                NSUInteger sectionIndex = [self.formDescriptor.formSections indexOfObject:object];
                [self formRowHasBeenRemoved:removedRow
                                                        atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
            }
        }
    }
}
-(void)dealloc
{
    [self removeObserver:self forKeyPath:ZLFormRowsKey];
    [self.formRows removeAllObjects];
    self.formRows = nil;
}


-(void)formRowHasBeenAdded:(ZLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
    
    UITableView *tableView = self.formDescriptor.tableView;
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:formRow.insertAnimation];
    [tableView endUpdates];
    if ([self.formDescriptor.delegate respondsToSelector:@selector(formDescriptor:formRowHasBeenAdded:atIndexPath:)]) {
        [self.formDescriptor.delegate formDescriptor:self.formDescriptor formRowHasBeenAdded:formRow
                                              atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    }
}

-(void)formRowHasBeenRemoved:(ZLFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
  
    UITableView *tableView = self.formDescriptor.tableView;
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:formRow.deleteAnimation];
    [tableView endUpdates];
    if ([self.formDescriptor.delegate respondsToSelector:@selector(formDescriptor:formRowHasBeenRemoved:atIndexPath:)]) {
        [self.formDescriptor.delegate formDescriptor:self.formDescriptor formRowHasBeenRemoved:formRow
                                                atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    }
}

@end
