//
//  ZLFormSubmitViewController.m
//  ZLForm
//
//  Created by admin on 2026/5/20.
//

#import "ZLFormSubmitViewController.h"
#import "ZLFormTextFieldCell.h"
#if __has_include(<ZLForm/ZLForm.h>)
#import <ZLForm/ZLForm.h>
#else
#import "ZLForm.h"
#endif

@interface ZLFormSubmitViewController ()<ZLFormDescriptorDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZLFormDescriptor *formDescriptor;
@end

@implementation ZLFormSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息提交";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupForm];
    [self setupTableView];
    [self setupSubmitButton];
}

#pragma mark - Setup

- (void)setupForm {
    self.formDescriptor = [ZLFormDescriptor formDescriptor];
    self.formDescriptor.delegate = self;
    
    // Section 1 - 基本信息
    ZLFormSectionDescriptor *basicSection = [[ZLFormSectionDescriptor alloc] initWithTag:@"basic"];
    basicSection.headerHeight = 44;
    basicSection.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 34)];
        label.text = @"基本信息";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 姓名
    ZLFormRowDescriptor *nameRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
    nameRow.title = @"姓名";
    nameRow.height = 50;
    nameRow.cellClass = [ZLFormTextFieldCell class];
   
    nameRow.placeholderValue = @"请输入";
    [nameRow addValidator:@"姓名不能为空" validationBlock:^BOOL(id value) {
        return value && [value length] > 0;
    }];
    [basicSection addFormRow:nameRow];
    
    // 手机号
    ZLFormRowDescriptor *phoneRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"phone"];
    phoneRow.title = @"手机号";
    phoneRow.height = 50;
    phoneRow.cellClass = [ZLFormTextFieldCell class];
    phoneRow.placeholderValue = @"请输入";
    [phoneRow addValidator:@"请输入正确的手机号" validationBlock:^BOOL(id value) {
        if (![value isKindOfClass:[NSString class]]) return NO;
        NSString *str = (NSString *)value;
        return str.length == 11;
    }];
    [basicSection addFormRow:phoneRow];
    
    // 邮箱
    ZLFormRowDescriptor *emailRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"email"];
    emailRow.title = @"邮箱";
    emailRow.height = 50;
    emailRow.cellClass = [ZLFormTextFieldCell class];
    emailRow.placeholderValue = @"请输入";
    [emailRow addValidator:@"请输入正确的邮箱" validationBlock:^BOOL(id value) {
        if (![value isKindOfClass:[NSString class]]) return NO;
        NSString *str = (NSString *)value;
        return [str containsString:@"@"] && [str containsString:@"."];
    }];
    [basicSection addFormRow:emailRow];
    
    [self.formDescriptor addFormSection:basicSection];
    
    // Section 2 - 工作信息
    ZLFormSectionDescriptor *workSection = [[ZLFormSectionDescriptor alloc] initWithTag:@"work"];
    workSection.headerHeight = 44;
    workSection.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 34)];
        label.text = @"工作信息";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 公司
    ZLFormRowDescriptor *companyRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"company"];
    companyRow.title = @"公司";
    companyRow.height = 50;
    companyRow.cellClass = [ZLFormTextFieldCell class];
    companyRow.placeholderValue = @"请输入";
    [companyRow addValidator:@"请输入公司名称" validationBlock:^BOOL(id value) {
        return value && [value length] > 0;
    }];
    [workSection addFormRow:companyRow];
    
    // 职位
    ZLFormRowDescriptor *positionRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"position"];
    positionRow.title = @"职位";
    positionRow.height = 50;
    positionRow.cellClass = [ZLFormTextFieldCell class];
    positionRow.placeholderValue = @"请输入";
    [workSection addFormRow:positionRow];
    
    // 工作年限
    ZLFormRowDescriptor *yearsRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"workYears"];
    yearsRow.title = @"工作年限";
    yearsRow.height = 50;
    yearsRow.cellClass = [ZLFormTextFieldCell class];
    yearsRow.placeholderValue = @"请输入";
    yearsRow.value = @"50";
    yearsRow.valueMapperToDisplay = ^id(id value) {
        if (value) {
            return [NSString stringWithFormat:@"%@ 年", value];
        }
        return value;
    };
    [workSection addFormRow:yearsRow];
    
    [self.formDescriptor addFormSection:workSection];
    
    // Section 3 - 备注
    ZLFormSectionDescriptor *remarkSection = [[ZLFormSectionDescriptor alloc] initWithTag:@"remark"];
    remarkSection.headerHeight = 44;
    remarkSection.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 34)];
        label.text = @"其他";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    ZLFormRowDescriptor *remarkRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"remark"];
    remarkRow.title = @"备注";
    remarkRow.height = 50;
    remarkRow.cellClass = [ZLFormTextFieldCell class];
    remarkRow.placeholderValue = @"选填";
    remarkRow.ignoreValue = NO;
    remarkRow.cellClass = [ZLFormTextFieldCell class];
    [remarkSection addFormRow:remarkRow];
    
    [self.formDescriptor addFormSection:remarkSection];
}

- (void)setupTableView {
    CGFloat bottomInset = 80;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
    self.formDescriptor.tableView = self.tableView;
    [self.view addSubview:self.tableView];
}

- (void)setupSubmitButton {
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    submitBtn.frame = CGRectMake(30, CGRectGetMaxY(self.view.bounds) - 80, CGRectGetWidth(self.view.bounds) - 60, 50);
    submitBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    submitBtn.backgroundColor = [UIColor systemBlueColor];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    submitBtn.layer.cornerRadius = 8;
    [submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
}

#pragma mark - Actions

- (void)submitAction {
    [self.formDescriptor validation];
}

#pragma mark - ZLFormDescriptorDelegate

- (void)formDescriptor:(ZLFormDescriptor *)form showFormValidationError:(ZLFormValidationStatus *)status {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"校验失败" message:status.msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)validationSuccessForFormDescriptor:(ZLFormDescriptor *)form {
    // 获取所有表单值
    NSDictionary *formValues = [self.formDescriptor formValues];
    NSLog(@"表单提交数据: %@", formValues);
    // 模拟提交
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"校验通过"
                                                                   message:[NSString stringWithFormat:@"提交数据:\n%@", formValues]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
