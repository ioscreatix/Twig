@interface SBFLockScreenDateView : UIView
@property (assign,nonatomic) CGFloat alignmentPercent;
@property (nonatomic, retain) UIView *weatherView;
@end


@interface WATodayPadView : UIView
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic,retain) UIView * locationLabel;                       //@synthesize locationLabel=_locationLabel - In the implementation block
@property (nonatomic,retain) UIView * conditionsLabel;  
@end

@interface WALockscreenWidgetViewController : UIViewController
@end

static BOOL IS_RTL = NO;
static BOOL RTL_IS_SET = NO;
static BOOL enabled = YES;
static BOOL conditions = NO;
static BOOL location = NO;

%group Twig
%hook SBFLockScreenDateView
%property (nonatomic, retain) UIView *weatherView;
- (CGFloat)alignmentPercent {
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	return IS_RTL ? -1.0 : 1.0;
}
- (void)setAlignmentPercent:(CGFloat)percent {
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	%orig(IS_RTL ? -1.0 : 1.0);
}
%end

@interface SBLockScreenDateViewController : UIViewController
@property (nonatomic, retain) UIViewController *weatherController;
@end


%hook SBLockScreenDateViewController
%property (nonatomic, retain) UIViewController *weatherController;
- (void)loadView {
	%orig;
	if (!RTL_IS_SET) {
		IS_RTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		RTL_IS_SET = YES;
	}
	self.weatherController = [[NSClassFromString(@"WALockscreenWidgetViewController") alloc] init];
	[self addChildViewController:self.weatherController];
	[self.weatherController didMoveToParentViewController:self];
	[self.view addSubview:self.weatherController.view];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.weatherController.view
			                                             attribute:NSLayoutAttributeCenterY
			                                             relatedBy:NSLayoutRelationEqual
			                                                toItem:self.view
			                                             attribute:NSLayoutAttributeCenterY
			                                            multiplier:1
			                                              constant:0]];

	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.weatherController.view
			                                             attribute:IS_RTL ? NSLayoutAttributeRight : NSLayoutAttributeLeft
			                                             relatedBy:NSLayoutRelationEqual
			                                                toItem:self.view
			                                             attribute:IS_RTL ? NSLayoutAttributeRight : NSLayoutAttributeLeft
			                                            multiplier:1
			                                              constant:0]];
}

- (void)setContentAlpha:(CGFloat)alpha withSubtitleVisible:(BOOL)subtitleVisible {
	%orig;
	if (self.weatherController)
		self.weatherController.view.alpha = alpha;
}
%end

%hook WATodayPadViewStyle
-(NSUInteger)format {
	return 2;
}
-(void)setFormat:(NSUInteger)arg1 {
	%orig(2);
}
-(id)initWithFormat:(NSUInteger)arg1 orientation:(NSInteger)arg2 {
	return %orig(2,arg2);
}
-(double)locationLabelBaselineToTemperatureLabelBaseline {
	if (enabled && location) {
		%orig;
	}
	return 0;
}
-(double)conditionsLabelBaselineToLocationLabelBaseline {
	if (enabled && location) {
		%orig;
	}
	return 0;
}
-(double)conditionsLabelBaselineToBottom {
	if (enabled && location) {
		%orig;
	}
	return 0;
}
%end

%hook WATodayPadView
- (void)layoutSubviews {
	%orig;
	if (self.conditionsLabel && conditions == NO) {
		self.conditionsLabel.hidden = YES;
		self.conditionsLabel.alpha = 0;
	} else {
		self.conditionsLabel.hidden = NO;
		self.conditionsLabel.alpha = 1;
	}

	if (self.locationLabel && location == NO) {
		self.locationLabel.alpha = 0;
		self.locationLabel.hidden = YES;
	} else {
		self.locationLabel.alpha = 1;
		self.locationLabel.hidden = NO;
	}
}
%end
%end

%ctor {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ioscreatix.plist"];

	if (enabled) {
		%init(Twig);
	}

	if (prefs) {
		if ([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}

		if ([prefs objectForKey:@"conditions"]) {
			conditions = [[prefs valueForKey:@"conditions"] boolValue];
		}

		if ([prefs objectForKey:@"location"]) {
			location = [[prefs valueForKey:@"location"] boolValue];
		}
	}
}