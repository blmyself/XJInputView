//
//  XJFaceEmojeView.m
//  XJTemplateProject
//
//  Created by 江鑫 on 2018/8/7.
//  Copyright © 2018年 XJ. All rights reserved.
//

/*待优化:
 1,长按表情展示图片加文字;
 2,异步加载第一页以后数据;
 3,动图,
 */

#import "XJFaceEmojeView.h"
#import "XJFaceInputHelper.h"
#import "XJInputDefine.h"

@implementation XJFaceButton

@end


@interface XJFaceEmojeView ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView *pageScrollVeiw;

@property(nonatomic, strong) UIPageControl *pageControl;

@property(nonatomic, strong) UIView *bottomBar;

@property(nonatomic, strong) UIButton *sendBtn;

@property(nonatomic, strong) NSDictionary *emojeDic;

@property(nonatomic, strong) NSMutableArray *allPageArray;

@property(nonatomic, assign) CGFloat imageHeight;

@end

@implementation XJFaceEmojeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupSubViews];
        [self configureEmojeData];
        [self configureEmojeView];
        
    }
    return self;
}

- (void)setupSubViews
{
    [self addSubview:self.pageScrollVeiw];
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.sendBtn];
    [self calculteImageHeight];
}

- (void)calculteImageHeight
{
    
   UIFont *font = [UIFont systemFontOfSize:17];
   NSDictionary *dict = @{NSFontAttributeName:font};
   CGSize maxsize = CGSizeMake(100, MAXFLOAT);
   CGSize size = [@"/" boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
  self.imageHeight = size.height;
    
}


- (void) configureEmojeView
{

    _pageScrollVeiw.contentSize = CGSizeMake(XJScreenWidth*self.allPageArray.count, FaceEmojeViewHeight-50);
    _pageControl.numberOfPages = self.allPageArray.count;
    
    for (int i = 0; i < self.allPageArray.count; i++) {
        
        UIView *faceBglView = [[UIView alloc]initWithFrame:CGRectMake(XJScreenWidth*i, 0, XJScreenWidth, self.frame.size.height-40)];
        faceBglView.backgroundColor = [UIColor whiteColor];
        [_pageScrollVeiw addSubview:faceBglView];
        
        NSArray *pageImageNameArray = self.allPageArray[i];
        for (int j = 0;j < pageImageNameArray.count; j++) {
            
            NSString *imageNamed = pageImageNameArray[j];
            XJFaceButton *emojeBtn = [XJFaceButton buttonWithType:UIButtonTypeCustom];
            emojeBtn.indexPath = [NSIndexPath indexPathForRow:j inSection:i];
//            UIImage *emojeImage = GETIMG(self.emojeDic[imageNamed]);
            UIImage *emojeImage = [self getBundleImage:self.emojeDic[imageNamed]];
            if (j == pageImageNameArray.count -1) {
                emojeImage = GETIMG(imageNamed);
                emojeBtn.isDleted = YES;
            }
            emojeBtn.emjeNamed = self.emojeDic[imageNamed];
            [emojeBtn setBackgroundImage:emojeImage forState:UIControlStateNormal];
            CGFloat spaceW = (XJScreenWidth-EmojeWH*8-2*20)/7;
            emojeBtn.frame = CGRectMake(20+j%8*(EmojeWH+spaceW),20+j/8*(EmojeWH+15), EmojeWH, EmojeWH);
            [faceBglView addSubview:emojeBtn];
            [emojeBtn addTarget:self action:@selector(clickEmoje:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
    /*富文本实现方案:
    for (int i = 0; i < allPageArray.count; i++) {
        YYLabel *facelab = [[YYLabel alloc]initWithFrame:CGRectMake(XJScreenWidth*i+10, 0, XJScreenWidth, self.frame.size.height-40)];
        facelab.tag = i;
        facelab.textAlignment = NSTextAlignmentCenter;
        facelab.backgroundColor = [UIColor whiteColor];
        facelab.numberOfLines = 0;
        [_pageScrollVeiw addSubview:facelab];
        
        NSMutableAttributedString *attributeText = [NSMutableAttributedString new];
        NSArray *pageImageNameArray = allPageArray[i];
        for (NSString *imageNamed in pageImageNameArray) {
            
          UIImage *emojeImage = GETIMG(self.emojeDic[imageNamed]);
//          if (!emojeImage) continue;
          YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc]initWithImage:emojeImage];
            
          NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(imageView.size.width+20, imageView.size.height+20) alignToFont:GETFONT(16) alignment:YYTextVerticalAlignmentCenter];
          [attributeText appendAttributedString:attachText];
        }
        facelab.attributedText = attributeText;
    }
     */
    
}

- (void)clickEmoje:(XJFaceButton*)sender
{
    
    //点击删除按钮:
    if (sender.isDleted == YES) {
        [self.textView deleteBackward];
        [self adjustContentTextViewHeight];
        return;
    }
    
    //富文本展示表情:
    UIImage *image = [self getBundleImage:sender.emjeNamed];
//    UIImage *image = [UIImage imageNamed:sender.emjeNamed];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    NSMutableAttributedString *attachmentString = (NSMutableAttributedString *)[NSAttributedString attributedStringWithAttachment:attachment];
    attachment.bounds = CGRectMake(0, -4, self.imageHeight, self.imageHeight);
    
    //UITextView附件:
    [self.textView.textStorage insertAttributedString:attachmentString atIndex:self.textView.selectedRange.location];
    self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 1, self.textView.selectedRange.length);
    
    //重置富文本属性:
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);
    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [_textView.textStorage addAttributes:[XJFaceInputHelper shareFaceHelper].attributes range:wholeRange];
    
    [self adjustContentTextViewHeight];
    
}

- (void) adjustContentTextViewHeight
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewClickHeightChanged)]) {
        
        [self.delegate faceViewClickHeightChanged];
        
    }
}


- (void)configureEmojeData
{
    self.allPageArray = [[XJFaceInputHelper shareFaceHelper]getAllEmojePage];
    self.emojeDic = [XJFaceInputHelper shareFaceHelper].emojeDic;
}

- (UIImage*)getBundleImage:(NSString*)imageNamed
{
   NSString *strResourcesBundle = [[NSBundle mainBundle] pathForResource:@"emoje1" ofType:@"bundle"];
   NSString *imgPath= [strResourcesBundle stringByAppendingPathComponent:imageNamed];
   UIImage *imgC = [UIImage imageWithContentsOfFile:imgPath];
   return imgC;
}

/**
 发送:
 */
- (void)sendBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendBtnClick)]) {
        [self.delegate faceViewSendBtnClick];
    }
}

#pragma mark -----  懒加载 ----------

- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.xj_width-200)/2, FaceEmojeViewHeight-30-BottomBarHeight, 200, 30)];
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor redColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.hidesForSinglePage = YES;
        [_pageControl addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageControl;
}

- (UIScrollView *)pageScrollVeiw {
    
    if (!_pageScrollVeiw) {
        _pageScrollVeiw = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, XJScreenWidth, 200)];
        _pageScrollVeiw.pagingEnabled = YES;
        _pageScrollVeiw.backgroundColor = [UIColor whiteColor];
        _pageScrollVeiw.bounces = NO;
        _pageScrollVeiw.delegate = self;
        _pageScrollVeiw.showsHorizontalScrollIndicator = NO;
    }
    return _pageScrollVeiw;
}

- (UIView *)bottomBar {
    
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.xj_height-BottomBarHeight, XJScreenWidth, BottomBarHeight)];
        _bottomBar.backgroundColor = XJColor(236, 237, 241);
    }
    return _bottomBar;
}

//发送按钮
- (UIButton *)sendBtn {
    
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(XJScreenWidth-60,0, 60, BottomBarHeight)];
        _sendBtn.titleLabel.font = GETFONT(16);
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.backgroundColor = XJColor(0, 186, 255);
        [_sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}


#pragma mark    ----- UIScrollViewDelegate -----

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSInteger index =  scrollView.contentOffset.x/XJScreenWidth;
    
    _pageControl.currentPage = index;
    
}

- (void)actionPage
{
    
    _pageScrollVeiw.contentOffset = CGPointMake(_pageControl.currentPage* XJScreenWidth, 0);
    
    [_pageControl setNeedsDisplay];
    
}












//    [self.textView scrollRectToVisible:CGRectMake(0, 0, _textView.contentSize.width, _textView.contentSize.height) animated:NO];
/*way1:UITextView:
 NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
 attachment.image = image;
 NSMutableAttributedString *attachmentString = (NSMutableAttributedString *)[NSAttributedString attributedStringWithAttachment:attachment];
 NSMutableAttributedString *vv =  [[NSMutableAttributedString alloc]initWithAttributedString:_contentTextView.attributedText];
 [vv appendAttributedString:attachmentString];
 */

//    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
//    NSMutableAttributedString *imageAttributed = [NSMutableAttributedString attachmentStringWithContent:image  contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:GETFONT(16) alignment:YYTextVerticalAlignmentCenter];
//    imageAttributed.font = GETFONT(16);
//    [attributeString appendAttributedString:imageAttributed];
//
//    self.textView.attributedText = attributeString;
//    [self adjustContentTextViewHeight];

//    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewClickEmojeString:emojeNamed:isClickDelete:)]) {
//
//        NSIndexPath *indexPath = sender.indexPath;
////        NSString *ff = self.allPageArray[indexPath.section][indexPath.row];
//        [self.delegate faceViewClickEmojeString:self.allPageArray[indexPath.section][indexPath.row] emojeNamed:sender.emjeNamed isClickDelete:sender.isDleted ];
//
//    }
@end