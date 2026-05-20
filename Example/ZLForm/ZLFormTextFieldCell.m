//
//  ZLFormTextFieldCell.m
//  ZLForm
//
//  Created by admin on 2026/5/20.
//

#import "ZLFormTextFieldCell.h"
#if __has_include(<ZLForm/ZLForm.h>)
#import <ZLForm/ZLForm.h>
#else
#import "ZLForm.h"
#endif

@interface ZLFormTextFieldCell ()<UITextFieldDelegate>
@property (nonatomic, strong, readwrite) UITextField *textField;
@end

@implementation ZLFormTextFieldCell

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textField = [[UITextField alloc] init];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.textColor = [UIColor darkTextColor];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.textField];
    
    // Layout: titleLabel on left, textField on right
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.titleLabel.widthAnchor constraintEqualToConstant:80],
        
        [self.textField.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:10],
        [self.textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.textField.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.textField.heightAnchor constraintEqualToConstant:36],
    ]];
    
    // Hide the detailLabel from base cell
    self.detailLabel.hidden = YES;
}

- (void)update {
    [super update];
    self.titleLabel.text = self.rowDescriptor.title;
    self.textField.text = [self.rowDescriptor valueForDisplay];
    self.textField.placeholder = self.rowDescriptor.emptyDisplayValue;
    self.textField.enabled = !self.rowDescriptor.disabled;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField {
    id oldValue = self.rowDescriptor.value;
    self.rowDescriptor.value = textField.text;
    if (self.rowDescriptor.onChangeBlock) {
        self.rowDescriptor.onChangeBlock(oldValue, textField.text, self.rowDescriptor);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
