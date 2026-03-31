#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EAPMHomeActionType) {
    EAPMHomeActionTypeFullStackCrash,
    EAPMHomeActionTypeAbort,
    EAPMHomeActionTypeFreeze,
    EAPMHomeActionTypeCustomException,
    EAPMHomeActionTypePageLoad,
    EAPMHomeActionTypePageScroll,
    EAPMHomeActionTypeNetworkRequest,
    EAPMHomeActionTypeCreateLog,
    EAPMHomeActionTypeUpdateNickname,
    EAPMHomeActionTypePlaceholder,
};

@interface EAPMHomeActionItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) EAPMHomeActionType actionType;

+ (instancetype)itemWithTitle:(NSString *)title actionType:(EAPMHomeActionType)actionType;

@end

@interface EAPMGradientBackgroundView : UIView

@end

@interface EAPMHeroHeaderView : UIView

- (void)configureWithInfoText:(NSString *)text;

@end

@interface EAPMSectionHeaderView : UIView

- (void)configureWithTitle:(NSString *)title;

@end

@interface EAPMInfoBannerView : UIView

- (void)configureWithText:(NSString *)text;

@end

@interface EAPMActionCardView : UIView

- (void)configureWithTitle:(NSString *)title;
- (void)setCardHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
