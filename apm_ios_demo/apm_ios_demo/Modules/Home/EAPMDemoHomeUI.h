#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EAPMDemoHomeActionHandler)(void);

typedef NS_ENUM(NSInteger, EAPMDemoHomeAlertActionStyle) {
    EAPMDemoHomeAlertActionStyleSecondary,
    EAPMDemoHomeAlertActionStylePrimary,
};

typedef NS_ENUM(NSInteger, EAPMDemoHomeAlertMessageAlignment) {
    EAPMDemoHomeAlertMessageAlignmentCenter,
    EAPMDemoHomeAlertMessageAlignmentLeft,
};

@interface EAPMDemoHomeActionItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;

+ (instancetype)itemWithTitle:(NSString *)title actionHandler:(EAPMDemoHomeActionHandler)actionHandler;
- (void)performAction;

@end

@interface EAPMDemoHomeSectionModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray<EAPMDemoHomeActionItem *> *items;

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<EAPMDemoHomeActionItem *> *)items;

@end

@interface EAPMDemoHomeAlertAction : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) EAPMDemoHomeAlertActionStyle style;
@property (nonatomic, copy, readonly, nullable) EAPMDemoHomeActionHandler handler;

+ (instancetype)actionWithTitle:(NSString *)title
                          style:(EAPMDemoHomeAlertActionStyle)style
                        handler:(nullable EAPMDemoHomeActionHandler)handler;

@end

@interface EAPMDemoHomeAlertPresenter : NSObject

+ (void)presentAlertFrom:(UIViewController *)presenter
                   title:(NSString *)title
                 message:(NSString *)message
                 actions:(NSArray<EAPMDemoHomeAlertAction *> *)actions;

+ (void)presentAlertFrom:(UIViewController *)presenter
                   title:(NSString *)title
                 message:(NSString *)message
        messageAlignment:(EAPMDemoHomeAlertMessageAlignment)messageAlignment
                 actions:(NSArray<EAPMDemoHomeAlertAction *> *)actions;

+ (void)presentAlertFrom:(UIViewController *)presenter
                   title:(NSString *)title
       attributedMessage:(NSAttributedString *)attributedMessage
                 actions:(NSArray<EAPMDemoHomeAlertAction *> *)actions;

@end

@interface EAPMDemoGradientBackgroundView : UIView

@end

@interface EAPMDemoHeroHeaderView : UIView

- (void)configureWithInfoText:(NSString *)text settingsHandler:(nullable EAPMDemoHomeActionHandler)settingsHandler;

@end

@interface EAPMDemoSectionHeaderView : UIView

- (void)configureWithTitle:(NSString *)title;

@end

@interface EAPMDemoInfoBannerView : UIView

- (void)configureWithText:(NSString *)text;

@end

@interface EAPMDemoActionCardView : UIView

- (void)configureWithTitle:(NSString *)title;
- (void)setCardHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
