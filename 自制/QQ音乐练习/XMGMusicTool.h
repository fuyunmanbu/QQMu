//
//  XMGMusicTool.h
//  QQMusic
//
//  Created by xiaomage on 15/8/15.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMGMusic;

@interface XMGMusicTool : NSObject
//返回所有的歌曲
+ (NSArray *)musics;
//返回正在播放的音乐
+ (XMGMusic *)playingMusic;
//设置正在播放的歌曲
+ (void)setPlayingMusic:(XMGMusic *)playingMusic;
// 上一首
+ (XMGMusic *)nextMusic;
// 下一首
+ (XMGMusic *)previousMusic;

@end
