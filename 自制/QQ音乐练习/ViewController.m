//
//  ViewController.m
//  QQ音乐练习
//
//  Created by 浮云漫步 on 16/6/22.
//  Copyright © 2016年 iphone. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "XMGMusic.h"
#import "XMGMusicTool.h"
#import "XMGAudioTool.h"
#import "NSString+XMGTimeExtension.h"
#import "CALayer+PauseAimate.h"
#import "XMGLrcView.h"
#import "XMGLrcLabel.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController ()<UIScrollViewDelegate,AVAudioPlayerDelegate>
/**
 *  背景图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
/**
 *  滑块
 */
@property (weak, nonatomic) IBOutlet UISlider *sliderBar;
/**
 *  圆形图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
// 歌词的View
@property (weak, nonatomic) IBOutlet XMGLrcView *lrcView;

// 歌词的Label
@property (weak, nonatomic) IBOutlet XMGLrcLabel *lrcLabel;

/** 歌词更新的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/** 进度的Timer */
@property (nonatomic, strong) NSTimer *progressTimer;

/** 当前的播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

#pragma mark - slider的事件处理
- (IBAction)startSlide;
- (IBAction)sliderValueChange;
- (IBAction)endSlide;
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

#pragma mark - 歌曲控制的事件处理
- (IBAction)playOrPause;
- (IBAction)previous;
- (IBAction)next;
@end

@implementation ViewController
- (IBAction)startSlide{
    [self removeProgressTimer];
}
- (IBAction)sliderValueChange{
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration * self.sliderBar.value];
}
- (IBAction)endSlide{
    //    设置歌曲进度
    self.currentPlayer.currentTime = self.sliderBar.value * self.currentPlayer.duration;
    
    [self addProgressTimer];
}

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:sender.view];
//    计算slider长度的比例
    CGFloat ratio = point.x / sender.view.bounds.size.width;
//    改变滑块的位置
//    self.sliderBar.value = ratio;
    
    self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;
    
    [self updateProgressInfo];
    
}
- (void)addLrcTimer
{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}
#pragma mark - 更新歌词
- (void)updateLrc
{
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}
#pragma mark - 歌曲控制的事件处理
- (IBAction)playOrPause{
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    if (self.currentPlayer.playing) {
        [self.currentPlayer pause];
        
        [self removeProgressTimer];
        [self removeLrcTimer];
//        暂停动画
        [self.headImage.layer pauseAnimate];
    }else {
        [self.currentPlayer play];
        [self addProgressTimer];
        
        [self removeLrcTimer];
//        回复动画
        [self.headImage.layer resumeAnimate];
    }
}
- (void)playingMusicWithMusic:(XMGMusic *)music
{
    // 1.停止当前歌曲
    XMGMusic *playingMusic = [XMGMusicTool playingMusic];
    [XMGAudioTool stopMusicWithMusicName:playingMusic.filename];
    
    // 3.播放歌曲
    [XMGAudioTool playMusicWithMusicName:music.filename];
    
    // 4.将工具类中的当前歌曲切换成播放的歌曲
    [XMGMusicTool setPlayingMusic:music];
    
    // 5.改变界面信息
    [self startPlaying];
}

- (IBAction)previous{
    
    // 1.取出上一首歌曲
    XMGMusic *previousMusic = [XMGMusicTool previousMusic];
    [self loadTable];
    self.lrcLabel.text = nil;
    // 2.播放歌曲
    [self playingMusicWithMusic:previousMusic];
}
// 让tableview复原到初始位置
- (void)loadTable{
    self.lrcView.tableView.contentOffset = CGPointMake( 0, -self.lrcView.bounds.size.height * 0.5);
}
- (IBAction)next{
    // 1.取出下一首歌曲
    XMGMusic *previousMusic = [XMGMusicTool nextMusic];
    [self loadTable];
    self.lrcLabel.text = nil;
    
    // 2.播放歌曲
    [self playingMusicWithMusic:previousMusic];
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    高斯模糊
    [self setBool];
    [self setSlider];
//    设置界面信息
    [self startPlaying];
    
    // 4.设置lrcView的ContentSize
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    self.lrcView.lrcLabel = self.lrcLabel;
    
}
- (void)startPlaying{
    XMGMusic *playing = [XMGMusicTool playingMusic];
    
    self.backImage.image = [UIImage imageNamed:playing.icon];
    self.headImage.image = [UIImage imageNamed:playing.icon];
    
    self.songLabel.text = playing.name;
    self.singerLabel.text = playing.singer;
    
//    开始播放
     self.currentPlayer = [XMGAudioTool playMusicWithMusicName:playing.filename];
    self.currentPlayer.delegate = self;
    self.totalTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration];
    
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    [self startIconViewAnimate];
    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
//    设置歌词
    self.lrcView.lrcName = playing.lrcname;
    self.lrcView.duration = self.currentPlayer.duration;
    //    更新界面
    [self removeProgressTimer];
    [self addProgressTimer];
    
    [self removeLrcTimer];
    [self addLrcTimer];
//    设置锁屏界面信息
//    [self setupLockScreenInfo];
}
- (void)startIconViewAnimate
{
    // 1.创建基本动画
    CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.设置基本动画属性
    rotateAnim.fromValue = @(0);
    rotateAnim.toValue = @(M_PI * 2);
    rotateAnim.repeatCount = NSIntegerMax;
    rotateAnim.duration = 40;
    
    // 3.添加动画到图层上
    [self.headImage.layer addAnimation:rotateAnim forKey:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //    设置圆角
    self.headImage.layer.cornerRadius = self.headImage.bounds.size.width * 0.5;
    self.headImage.layer.masksToBounds = YES;
    
    self.headImage.layer.borderWidth = 8.0;
    self.headImage.layer.borderColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1].CGColor;
}
- (void)setSlider{
    [self.sliderBar setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
}
- (void)setBool{
    UIToolbar *tool = [[UIToolbar alloc]init];
    tool.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backImage addSubview:tool];
    [tool setBarStyle:UIBarStyleBlack];
    [tool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backImage.mas_top);
        make.bottom.equalTo(self.backImage.mas_bottom);
        make.left.equalTo(self.backImage.mas_left);
        make.right.equalTo(self.backImage.mas_right);
    }];
}
#pragma mark - 对定时器的操作
- (void)addProgressTimer
{
    [self updateProgressInfo];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}
- (void)updateProgressInfo
{
    // 1.设置当前的播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 2.更新滑块的位置
    self.sliderBar.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    
    CGFloat ratio = 1 - point.x / scrollView.bounds.size.width;
    
    self.headImage.alpha = ratio;
    self.lrcLabel.alpha = ratio;
}
//- (void)setupLockScreenInfo
//{
//    // 0.获取当前正在播放的歌曲
//    XMGMusic *playingMusic = [XMGMusicTool playingMusic];
//    
//    // 1.获取锁屏界面中心
//    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
//    
//    // 2.设置展示的信息
//    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
//    // 设置歌曲名称
//    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
//    // 设置歌手
//    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
//    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
//    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
//    [playingInfo setObject:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
//    
//    playingInfoCenter.nowPlayingInfo = playingInfo;
//    
//    // 3.让应用程序可以接受远程事件
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//}
// 监听远程事件（如：在锁屏状态下点击下一首）
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self next];
    }
}
@end
