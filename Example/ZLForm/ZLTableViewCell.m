//
//  ZLTableViewCell.m
//  ZLForm_Example
//
//  Created by admin on 2026/5/26.
//  Copyright © 2026 fanpeng. All rights reserved.
//

#import "ZLTableViewCell.h"


@interface ZLBox<ObjectType> : NSObject
@property(nonatomic,strong) ObjectType value;
@end
@implementation ZLBox
@end

@interface ZLTableViewCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation ZLTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLabels];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupLabels];
}

- (void)setupLabels {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16].active = YES;
        [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10].active = YES;
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16].active = YES;
       
    }
    
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.numberOfLines = 0;
        [self.contentView addSubview:_detailLabel];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_detailLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16].active = YES;
        [_detailLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4].active = YES;
        [_detailLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16].active = YES;
        [_detailLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10].active = YES;
    }
}

- (void)setRowDescriptor:(ZLFormRowDescriptor *)rowDescriptor {
    _rowDescriptor = rowDescriptor;
    self.titleLabel.text = rowDescriptor.title;
    self.detailLabel.text = [rowDescriptor.value isKindOfClass:[NSString class]] ? (NSString *)rowDescriptor.value : rowDescriptor.placeholderValue;
}

- (CGFloat)cellHeightForRowDescriptor:(ZLFormRowDescriptor *)rowDescriptor {
    return 0; // 0 表示用自动布局高度
}

@synthesize rowDescriptor = _rowDescriptor;

@end


