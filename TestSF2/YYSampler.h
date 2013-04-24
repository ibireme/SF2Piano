

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


/**
 * @see http://developer.apple.com/library/mac/#technotes/tn2283/_index.html
 */
@interface YYSampler : NSObject

- (OSStatus)loadFromDLSOrSoundFont:(NSURL *)bankURL withPatch:(int)presetNumber;

- (void)triggerNote:(NSUInteger)note;
- (void)triggerNote:(NSUInteger)note isOn:(BOOL)isOn;

@end
