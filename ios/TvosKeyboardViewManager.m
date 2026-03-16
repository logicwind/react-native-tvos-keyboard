#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(TvosKeyboardViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onTextChange, RCTBubblingEventBlock)
RCT_EXTERN_METHOD(focusSearchBar:(nonnull NSNumber *)reactTag)
RCT_EXPORT_VIEW_PROPERTY(onFocus, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBlur, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onKeyboardLayoutChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(gridSeparatorColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(linearSeparatorColor, UIColor)

@end
