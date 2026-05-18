//
//  ZLViewController.m
//  ZLForm
//
//  Created by fanpeng on 05/14/2026.
//  Copyright (c) 2026 fanpeng. All rights reserved.
//

#import "ZLViewController.h"
#if __has_include(<ZLForm/ZLForm.h>)
#import <ZLForm/ZLForm.h>
#else
#import "ZLForm.h"
#endif

@interface ZLViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZLFormDescriptor *formDescriptor;
@end

@implementation ZLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"ZLForm Demo";
    [self setupForm];
    [self setupTableView];
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
    nameRow.required = YES;
    nameRow.valueMapperToDisplay = ^id _Nonnull(id  _Nonnull value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSString stringWithFormat:@"%@ (必填)", value];
        }
        return value;
    };
    nameRow.requireMsg = @"请输入姓名";
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
    return self.formDescriptor.formSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    return sectionDescriptor.formRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    
    ZLFormBaseCell *cell = [rowDescriptor cellForFormController:self];
    cell.titleLabel.text = rowDescriptor.title;
    cell.detailLabel.text = rowDescriptor.valueForDisplay;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    return rowDescriptor.height > 0 ? rowDescriptor.height : 44.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    return sectionDescriptor.headerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    if (sectionDescriptor.headerViewBlock) {
        return sectionDescriptor.headerViewBlock(sectionDescriptor);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    return sectionDescriptor.footerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    if (sectionDescriptor.footerViewBlock) {
        return sectionDescriptor.footerViewBlock(sectionDescriptor);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[section];
    return sectionDescriptor.tag;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZLFormSectionDescriptor *sectionDescriptor = self.formDescriptor.formSections[indexPath.section];
    ZLFormRowDescriptor *rowDescriptor = sectionDescriptor.formRows[indexPath.row];
    NSLog(@"选中: %@ = %@", rowDescriptor.title, rowDescriptor.value);
}

@end
