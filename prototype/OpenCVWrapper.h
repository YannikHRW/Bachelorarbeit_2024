#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
- (NSDictionary *)detectEdgesAndLines:(UIImage *)image;
@end
