#import <UIKit/UIKit.h>
#import "../Shared/EAPMDemoOverlayPresenter.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EAPMDemoHomeActionHandler)(void);

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
