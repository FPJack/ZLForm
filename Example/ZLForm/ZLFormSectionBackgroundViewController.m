//
//  ZLFormSectionBackgroundViewController.m
//  ZLForm
//
//  Created by admin on 2026/5/22.
//

#import "ZLFormSectionBackgroundViewController.h"
@import ZLForm;

@interface ZLFormSectionBackgroundViewController ()<ZLFormDescriptorDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZLFormDescriptor *formDescriptor;
@property (nonatomic, assign) NSInteger rowCounter;
@end

@implementation ZLFormSectionBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Section背景Demo";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.rowCounter = 0;
    [self setupForm];
    [self setupTableView];
    [self setupNavigationBar];
}

#pragma mark - NavigationBar

- (void)setupNavigationBar {
    UIBarButtonItem *addRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"＋Row" style:UIBarButtonItemStylePlain target:self action:@selector(addRowAction)];
    UIBarButtonItem *removeRowBtn = [[UIBarButtonItem alloc] initWithTitle:@"－Row" style:UIBarButtonItemStylePlain target:self action:@selector(removeRowAction)];
    UIBarButtonItem *toggleBtn = [[UIBarButtonItem alloc] initWithTitle:@"隐/显Row" style:UIBarButtonItemStylePlain target:self action:@selector(toggleRowHidden)];
    self.navigationItem.rightBarButtonItems = @[addRowBtn, removeRowBtn, toggleBtn];
}

#pragma mark - Setup

- (void)setupForm {
    self.formDescriptor = [ZLFormDescriptor formDescriptor];
    self.formDescriptor.delegate = self;
    
    // Section 1
    ZLFormSectionDescriptor *section1 = [[ZLFormSectionDescriptor alloc] initWithTag:@"section1"];
    section1.headerHeight = 40;
    section1.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 32)];
        label.text = @"个人信息";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 背景 view
    UIView *bg1 = [[UIView alloc] init];
    bg1.backgroundColor = [UIColor whiteColor];
    bg1.layer.cornerRadius = 12;
    bg1.layer.shadowColor = [UIColor blackColor].CGColor;
    bg1.layer.shadowOpacity = 0.08;
    bg1.layer.shadowOffset = CGSizeMake(0, 2);
    bg1.layer.shadowRadius = 6;
    section1.sectionBackgroundView = bg1;
    section1.sectionBackgroundInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    
    ZLFormRowDescriptor *nameRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"name"];
    nameRow.title = @"姓名";
    nameRow.value = @"张三";
    nameRow.height = 50;
    [section1 addFormRow:nameRow];
    
    ZLFormRowDescriptor *phoneRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"phone"];
    phoneRow.title = @"电话";
    phoneRow.value = @"13800138000";
    phoneRow.height = 50;
    [section1 addFormRow:phoneRow];
    
    ZLFormRowDescriptor *emailRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"email"];
    emailRow.title = @"邮箱";
    emailRow.value = @"test@example.com";
    emailRow.height = 50;
    [section1 addFormRow:emailRow];
    
    [self.formDescriptor addFormSection:section1];
    
    // Section 2
    ZLFormSectionDescriptor *section2 = [[ZLFormSectionDescriptor alloc] initWithTag:@"section2"];
    section2.headerHeight = 40;
    section2.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 32)];
        label.text = @"工作信息";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 背景 view - 蓝色调
    UIView *bg2 = [[UIView alloc] init];
    bg2.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.05];
    bg2.layer.cornerRadius = 12;
    bg2.layer.borderWidth = 1;
    bg2.layer.borderColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.2].CGColor;
    section2.sectionBackgroundView = bg2;
    section2.sectionBackgroundInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    
    ZLFormRowDescriptor *companyRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"company"];
    companyRow.title = @"公司";
    companyRow.value = @"ABC科技";
    companyRow.height = 50;
    [section2 addFormRow:companyRow];
    
    ZLFormRowDescriptor *positionRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"position"];
    positionRow.title = @"职位";
    positionRow.value = @"iOS开发";
    positionRow.height = 50;
    [section2 addFormRow:positionRow];
    
    [self.formDescriptor addFormSection:section2];
    
    // Section 3
    ZLFormSectionDescriptor *section3 = [[ZLFormSectionDescriptor alloc] initWithTag:@"section3"];
    section3.headerHeight = 40;
    section3.headerViewBlock = ^UIView * _Nullable(ZLFormSectionDescriptor * _Nonnull sec) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 300, 32)];
        label.text = @"动态添加区域";
        label.font = [UIFont boldSystemFontOfSize:16];
        return label;
    };
    
    // 背景 view - 绿色调
    UIView *bg3 = [[UIView alloc] init];
    bg3.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.06];
    bg3.layer.cornerRadius = 12;
    bg3.layer.borderWidth = 1;
    bg3.layer.borderColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.3].CGColor;
    section3.sectionBackgroundView = bg3;
    section3.sectionBackgroundInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    
    ZLFormRowDescriptor *defaultRow = [ZLFormRowDescriptor formRowDescriptorWithTag:@"dynamic_default"];
    defaultRow.title = @"默认行";
    defaultRow.value = @"点击右上角动态操作";
    defaultRow.height = 50;
    [section3 addFormRow:defaultRow];
    
    [self.formDescriptor addFormSection:section3];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.formDescriptor.tableView = self.tableView;
    [self.view addSubview:self.tableView];
}

#pragma mark - Actions

- (void)addRowAction {
    // 在第三个 section 动态添加 row，背景自动扩展
    ZLFormSectionDescriptor *section3 = self.formDescriptor.allSections.lastObject;
    self.rowCounter++;
    NSString *tag = [NSString stringWithFormat:@"dynamic_%ld", (long)self.rowCounter];
    ZLFormRowDescriptor *row = [ZLFormRowDescriptor formRowDescriptorWithTag:tag];
    row.title = [NSString stringWithFormat:@"动态行 %ld", (long)self.rowCounter];
    row.value = [NSString stringWithFormat:@"值_%ld", (long)self.rowCounter];
    row.height = 50;
    [section3 addFormRow:row];
}

- (void)removeRowAction {
    // 删除第三个 section 最后一行，背景自动收缩
    ZLFormSectionDescriptor *section3 = self.formDescriptor.allSections.lastObject;
//    if (section3.formRows.count <= 1) {
//        NSLog(@"至少保留一行");
//        return;
//    }
    ZLFormRowDescriptor *lastRow = section3.formRows.lastObject;
    [section3 removeFormRow:lastRow];
}

- (void)toggleRowHidden {
    // 隐藏/显示第一个 section 的第二行(电话)，背景自动调整
    ZLFormSectionDescriptor *section1 = self.formDescriptor.allSections.firstObject;
    if (section1.formRows.count < 2) return;
    ZLFormRowDescriptor *phoneRow = section1.formRows[1];
    phoneRow.hidden = !phoneRow.hidden;
    [self.formDescriptor reloadVisibility];
}

#pragma mark - ZLFormDescriptorDelegate

- (void)formDescriptor:(ZLFormDescriptor *)form didSelectFormRow:(ZLFormRowDescriptor *)formRow {
    NSLog(@"选中: %@ = %@", formRow.title, formRow.value);
}

@end
