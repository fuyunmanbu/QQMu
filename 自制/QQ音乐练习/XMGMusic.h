//
//  musicsModal.h
//  QQ音乐练习
//
//  Created by 浮云漫步 on 16/6/22.
//  Copyright © 2016年 iphone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGMusic : NSObject
/** 歌曲路径 */
@property (nonatomic , copy) NSString *filename;
/** 歌名 */
@property (nonatomic , copy) NSString *name;

@property (nonatomic , copy) NSString *lrcname;
@property (nonatomic , copy) NSString *singerIcon;
@property (nonatomic , copy) NSString *singer;
@property (nonatomic , copy) NSString *icon;

@end
