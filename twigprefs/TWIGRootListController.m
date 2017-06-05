#include "TWIGRootListController.h"

@implementation TWIGRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)respring {
	system("killall SpringBoard");
}

@end
