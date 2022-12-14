//
//  XXTEMoreTitleDescriptionCell.m
//  XXTExplorer
//
//  Created by Zheng Wu on 06/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMoreTitleDescriptionCell.h"

@interface XXTEMoreTitleDescriptionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;

@end

@implementation XXTEMoreTitleDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.titleLabel.textColor = XXTColorPlainTitleText();
    self.valueLabel.textColor = XXTColorPlainSubtitleText();
    self.descriptionLabel.textColor = XXTColorForeground();
    self.backgroundColor = XXTColorPlainBackground();
    self.tintColor = XXTColorForeground();
    
    self.titleLabel.text = @"";
    self.descriptionLabel.text = @"";
    self.valueLabel.text = @"";
    self.iconImage = nil;
    
    UIView *selectionBackground = [[UIView alloc] init];
    selectionBackground.backgroundColor = XXTColorCellSelected();
    self.selectedBackgroundView = selectionBackground;
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    self.iconImageView.image = iconImage;
    if (iconImage) {
        self.leftConstraint.constant = 16.0;
        self.iconWidthConstraint.constant = 44.0;
    } else {
        self.leftConstraint.constant = 0.0;
        self.iconWidthConstraint.constant = 0.0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
