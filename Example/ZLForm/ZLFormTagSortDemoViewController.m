//
//  ZLFormTagSortDemoViewController.m
//  ZLForm
//
//  Created by admin on 2026/5/26.
//

#import <UIKit/UIKit.h>
#import "ZLFormTagSortDemoViewController.h"
#import "ZLTableViewCell.h"

@implementation ZLFormTagSortDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tag排序Demo";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self setupForm];
    [self setupTableView];
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    UIBarButtonItem *addSectionBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋Section" style:UIBarButtonItemStylePlain target:self action:@selector(addSectionAction)];
    UIBarButtonItem *removeSectionBtn = [[UIBarButtonItem alloc] initWithTitle:@"－Section" style:UIBarButtonItemStylePlain target:self action:@selector(removeSectionAction)];
    UIBarButtonItem *addRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋Row" style:UIBarButtonItemStylePlain target:self action:@selector(addRowAction)];
    UIBarButtonItem *removeRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"－Row" style:UIBarButtonItemStylePlain target:self action:@selector(removeRowAction)];
    self.navigationItem.rightBarButtonItems = @[addSectionBtn, removeSectionBtn, addRowBtn, removeRowBtn];
}

- (void)setupForm {
    self.formDescriptor = [ZLFormDescriptor formDescriptor];
    self.formDescriptor.sortByTag = YES;
    // 初始添加2个section
    for (NSInteger i = 0; i < 2; i++) {
        NSString *tag = [NSString stringWithFormat:@"section_%ld", (long)i];
        ZLFormSectionDescriptor *section = [[ZLFormSectionDescriptor alloc] initWithTag:tag];
        section.headerHeight = 40;
        section.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 32)];
            label.text = [NSString stringWithFormat:@"Section %@", sec.tag];
            label.font = [UIFont boldSystemFontOfSize:16];
            return label;
        };
        // 初始每组加2行
        for (NSInteger j = 0; j < 2; j++) {
            NSString *rowTag = [NSString stringWithFormat:@"row_%ld_%ld", (long)i, (long)j];
            ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:rowTag];
            row.title = [NSString stringWithFormat:@"Row %@", rowTag];
            row.value = [NSString stringWithFormat:@"Value_%ld_%ld", (long)i, (long)j];
            row.cellClass = [ZLTableViewCell class];
            [section addFormRow:row];
        }
        [self.formDescriptor addFormSection:section];
    }
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.formDescriptor.tableView = self.tableView;
    [self.view addSubview:self.tableView];
}

#pragma mark - Actions

- (void)addSectionAction {
    NSInteger idx = self.formDescriptor.allSections.count;
    NSString *tag = [NSString stringWithFormat:@"section_%ld", (long)idx];
    ZLFormSectionDescriptor *section = [[ZLFormSectionDescriptor alloc] initWithTag:tag];
    section.headerHeight = 40;
    section.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 32)];
        label.text = [NSString stringWithFormat:@"Section %@", sec.tag];
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    // 新section加2行
    for (NSInteger j = 0; j < 2; j++) {
        NSString *rowTag = [NSString stringWithFormat:@"row_%ld_%ld", (long)idx, (long)j];
        ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:rowTag];
        row.title = [NSString stringWithFormat:@"Row %@", rowTag];
        row.value = [NSString stringWithFormat:@"Value_%ld_%ld", (long)idx, (long)j];
        row.cellClass = [ZLTableViewCell class];
        [section addFormRow:row];
    }
    [self.formDescriptor addFormSection:section];
}

- (void)removeSectionAction {
    if (self.formDescriptor.allSections.count == 0) return;
    [self.formDescriptor removeFormSection:self.formDescriptor.allSections.lastObject];
}

- (void)addRowAction {
    if (self.formDescriptor.allSections.count == 0) return;
    ZLFormSectionDescriptor *section = self.formDescriptor.allSections.firstObject;
    NSInteger idx = section.formRows.count;
    NSString *rowTag = [NSString stringWithFormat:@"row_%@_%ld", section.tag, (long)idx];
    ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:rowTag];
    row.title = [NSString stringWithFormat:@"Row %@", rowTag];
    row.value = [NSString stringWithFormat:@"Value_%@_%ld", section.tag, (long)idx];
    row.cellClass = [ZLTableViewCell class];
    [section addFormRow:row];
}

- (void)removeRowAction {
    if (self.formDescriptor.allSections.count == 0) return;
    ZLFormSectionDescriptor *section = self.formDescriptor.allSections.firstObject;
    if (section.formRows.count == 0) return;
    [section removeFormRow:section.formRows.lastObject];
}

#pragma mark - ZLFormDescriptorDelegate

- (void)formDescriptor:(ZLFormDescriptor *)form didSelectFormRow:(ZLFormRowDescriptor *)formRow {
    NSLog(@"选中: %@ = %@", formRow.title, formRow.value);
}

@end
