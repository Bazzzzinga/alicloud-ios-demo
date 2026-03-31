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
};

@interface EAPMHomeActionItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) EAPMHomeActionType actionType;

+ (instancetype)itemWithTitle:(NSString *)title actionType:(EAPMHomeActionType)actionType;

@end

@interface EAPMGradientBackgroundView : UIView

@end

@interface EAPMHeroHeaderView : UIView

@end

@interface EAPMSectionHeaderView : UIView

@property (nonatomic, copy, nullable) dispatch_block_t accessoryTapHandler;

- (void)configureWithTitle:(NSString *)title accessoryTitle:(nullable NSString *)accessoryTitle;

@end

@interface EAPMActionCardView : UIView

- (void)configureWithTitle:(NSString *)title;
- (void)setCardHighlighted:(BOOL)highlighted;

@end

@interface EAPMInfoLinkView : UIControl

- (void)configureWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
