//
//  ZLViewController.m
//  ZLForm
//
//  Created by fanpeng on 05/14/2026.
//  Copyright (c) 2026 fanpeng. All rights reserved.
//

#import "ZLViewController.h"
#import "ZLFormSubmitViewController.h"
@import ZLForm;

@interface ZLViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZLFormDescriptor *formDescriptor;
@property (nonatomic, assign) NSInteger sectionCounter;
@property (nonatomic, assign) NSInteger rowCounter;
@end

@implementation ZLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"ZLForm Demo";
    self.sectionCounter = 0;
    self.rowCounter = 0;
    [self setupForm];
    [self setupTableView];
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle:@"表单提交" style:UIBarButtonItemStylePlain target:self action:@selector(pushSubmitForm)];
    UIBarButtonItem *addSectionBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋Section" style:UIBarButtonItemStylePlain target:self action:@selector(addSectionAction)];
    UIBarButtonItem *addRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋Row" style:UIBarButtonItemStylePlain target:self action:@selector(addRowAction)];
    self.navigationItem.rightBarButtonItems = @[submitBtn, addSectionBtn, addRowBtn];
    
    UIBarButtonItem *removeSectionBtn = [[UIBarButtonItem alloc] initWithTitle:@"－Section" style:UIBarButtonItemStylePlain target:self action:@selector(removeSectionAction)];
    UIBarButtonItem *removeRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"－Row" style:UIBarButtonItemStylePlain target:self action:@selector(removeRowAction)];
    self.navigationItem.leftBarButtonItems = @[removeSectionBtn, removeRowBtn];
}

- (void)pushSubmitForm {
    ZLFormSubmitViewController *vc = [[ZLFormSubmitViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Dynamic Add/Remove

- (void)addSectionAction {
    self.sectionCounter++;
    NSString *tag = [NSString stringWithFormat:@"newSection_%ld", (long)self.sectionCounter];
    ZLFormSectionDescriptor *section = [[ZLFormSectionDescriptor alloc] initWithTag:tag];
    section.headerHeight = 40;
    section.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sectionDescriptor) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 40)];
        label.text = [NSString stringWithFormat:@"新增Section - %@", sectionDescriptor.tag];
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 默认添加一行
    ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"newRow_s%ld_0", (long)self.sectionCounter]];
    row.title = [NSString stringWithFormat:@"新增行 (Section %ld)", (long)self.sectionCounter];
    row.value = @"默认值";
    row.height = 50;
    [section addFormRow:row];
    
    [self.formDescriptor addFormSection:section];
}

- (void)addRowAction {
    // 在最后一个section中添加一行
    if (self.formDescriptor.sectionDescriptors.count == 0) {
        NSLog(@"没有Section，请先添加Section");
        return;
    }
    ZLFormSectionDescriptor *lastSection = self.formDescriptor.sectionDescriptors.lastObject;
    self.rowCounter++;
    NSString *tag = [NSString stringWithFormat:@"dynamicRow_%ld", (long)self.rowCounter];
    ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:tag];
    row.title = [NSString stringWithFormat:@"动态行 %ld", (long)self.rowCounter];
    row.value = [NSString stringWithFormat:@"值_%ld", (long)self.rowCounter];
    row.height = 50;
    [lastSection addFormRow:row];
}

- (void)removeSectionAction {
    if (self.formDescriptor.sectionDescriptors.count == 0) {
        NSLog(@"已经没有Section可以删除");
        return;
    }
    ZLFormSectionDescriptor *lastSection = self.formDescriptor.sectionDescriptors.lastObject;
    [self.formDescriptor removeFormSection:lastSection];
//    [self.tableView reloadData];
}

- (void)removeRowAction {
    // 删除最后一个section的最后一行
    if (self.formDescriptor.sectionDescriptors.count == 0) {
        NSLog(@"没有Section");
        return;
    }
    ZLFormSectionDescriptor *lastSection = self.formDescriptor.sectionDescriptors.lastObject;
    if (lastSection.formRows.count == 0) {
        NSLog(@"该Section没有Row可删除");
        return;
    }
    ZLFormRowDescriptor *lastRow = lastSection.formRows.lastObject;
    [lastSection removeFormRow:lastRow];
//    [self.tableView reloadData];
}

- (void)setupForm {
    self.formDescriptor = [ZLFormDescriptor formDescriptor];
    
    // Section 1 - 个人信息
    ZLFormSectionDescriptor *section1 = [[ZLFormSectionDescriptor alloc] initWithTag:@"personalInfo"];
    section1.headerHeight = 40;
    section1.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sectionDescriptor) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 40)];
        headerLabel.text = @"个人信息";
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        return headerLabel;
    };
    
    ZLFormRowDescriptor *nameRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
    nameRow.title = @"姓名";
    nameRow.value = @"张三";
    nameRow.height = 50;
    nameRow.valueMapperToDisplay = ^id _Nonnull(id  _Nonnull value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSString stringWithFormat:@"%@ (必填)", value];
        }
        return value;
    };
    nameRow.onChangeBlock = ^(id oldValue, id newValue, ZLFormRowDescriptor *rowDescriptor) {
        NSLog(@"姓名变更: %@ -> %@", oldValue, newValue);
    };
    [nameRow addValidator:@"请输入姓名" validationBlock:^BOOL(id  _Nonnull value) {
        return YES;
    }];
    [section1 addFormRow:nameRow];
    
    ZLFormRowDescriptor *phoneRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"phone"];
    phoneRow.title = @"电话";
    phoneRow.value = @"13800138000";
    phoneRow.height = 50;
    [section1 addFormRow:phoneRow];
    
    ZLFormRowDescriptor *emailRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"email"];
    emailRow.title = @"邮箱";
    emailRow.value = @"zhangsan@example.com";
    emailRow.height = 50;
    [section1 addFormRow:emailRow];
    
    [self.formDescriptor addFormSection:section1];
    
    // Section 2 - 其他信息
    ZLFormSectionDescriptor *section2 = [[ZLFormSectionDescriptor alloc] initWithTag:@"otherInfo"];
    section2.headerHeight = 40;
    section2.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sectionDescriptor) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 40)];
        headerLabel.text = @"公司信息";
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        return headerLabel;
    };
    ZLFormRowDescriptor *addressRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"address"];
    addressRow.title = @"地址";
    addressRow.value = @"北京市朝阳区";
    addressRow.height = 50;
    [section2 addFormRow:addressRow];
    
    ZLFormRowDescriptor *companyRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"company"];
    companyRow.title = @"公司";
    companyRow.value = @"ABC科技有限公司";
    companyRow.height = 50;
    [section2 addFormRow:companyRow];
    
    [self.formDescriptor addFormSection:section2];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.formDescriptor.tableView = self.tableView;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.formDescriptor.sectionDescriptors.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    return sectionDescriptor.formRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    
    ZLFormBaseCell *cell = [rowDescriptor cellForFormController:self];
    cell.titleLabel.text = rowDescriptor.title;
    cell.detailLabel.text = rowDescriptor.valueForDisplay;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    return rowDescriptor.height > 0 ? rowDescriptor.height : 44.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    return sectionDescriptor.headerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    if (sectionDescriptor.headerViewBlock) {
        return sectionDescriptor.headerViewBlock(sectionDescriptor);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    return sectionDescriptor.footerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    if (sectionDescriptor.footerViewBlock) {
        return sectionDescriptor.footerViewBlock(sectionDescriptor);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[section];
    return sectionDescriptor.tag;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.sectionDescriptors[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    NSLog(@"选中: %@ = %@", rowDescriptor.title, rowDescriptor.value);
}

@end
