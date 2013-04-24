

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "YYSampler.h"

@interface YYViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *samplerTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *kbdScrollView;
@property (nonatomic, retain) YYSampler *sampler;
@end
