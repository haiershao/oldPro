/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"

@interface UIImageView (RecodPictureCache)

- (void)sd_RecodPictureCache_setImageWithCid:(NSString*)cid fileName:(NSString*)name recordType:(NSUInteger)type placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;


@end
