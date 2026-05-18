//
//  ZLFormBaseCell.m
//  ZLForm
//
//  Created by admin on 2026/5/14.
//

#import "ZLFormBaseCell.h"

@implementation ZLFormBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
        [self configure];
    }
    return self;
}
- (void)configure{
}

- (void)update
{
    
}
- (void)setupSubviews {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont systemFontOfSize:15];
    _detailLabel.textColor = [UIColor grayColor];
    _detailLabel.textAlignment = NSTextAlignmentRight;
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_detailLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_titleLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:0.4],
        
        [_detailLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_detailLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_detailLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:_titleLabel.trailingAnchor constant:8],
    ]];
}

@end
