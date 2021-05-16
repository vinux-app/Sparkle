//
//  SUUpdatePermissionPrompt.m
//  Sparkle
//
//  Created by Andy Matuschak on 1/24/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUUpdatePermissionPrompt.h"
#import "SPUUpdatePermissionRequest.h"
#import "SUUpdatePermissionResponse.h"
#import "SULocalizations.h"

#import "SUHost.h"
#import "SUConstants.h"
#import "SUApplicationInfo.h"
#import "SUTouchBarForwardDeclarations.h"
#import "SUTouchBarButtonGroup.h"

static NSString *const SUUpdatePermissionPromptTouchBarIndentifier = @"" SPARKLE_BUNDLE_IDENTIFIER ".SUUpdatePermissionPrompt";

@interface SUUpdatePermissionPrompt () <NSTouchBarDelegate>

@property (nonatomic) BOOL shouldSendProfile;

@property (nonatomic) SUHost *host;
@property (nonatomic) NSArray *systemProfileInformationArray;

@property (nonatomic) IBOutlet NSStackView *stackView;
@property (nonatomic) IBOutlet NSView *promptView;
@property (nonatomic) IBOutlet NSView *moreInfoView;
@property (nonatomic) IBOutlet NSView *responseView;
@property (nonatomic) IBOutlet NSView *infoChoiceView;

@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic) IBOutlet NSButton *checkButton;

@property (nonatomic, readonly) void (^reply)(SUUpdatePermissionResponse *);

@end

@implementation SUUpdatePermissionPrompt

@synthesize reply = _reply;
@synthesize shouldSendProfile = _shouldSendProfile;
@synthesize host = _host;
@synthesize systemProfileInformationArray = _systemProfileInformationArray;
@synthesize stackView = _stackView;
@synthesize promptView = _promtView;
@synthesize moreInfoView = _moreInfoView;
@synthesize responseView = _responseView;
@synthesize infoChoiceView = _infoChoiceView;
@synthesize cancelButton = _cancelButton;
@synthesize checkButton = _checkButton;

- (instancetype)initPromptWithHost:(SUHost *)theHost request:(SPUUpdatePermissionRequest *)request reply:(void (^)(SUUpdatePermissionResponse *))reply
{
    self = [super initWithWindowNibName:@"SUUpdatePermissionPrompt"];
    if (self)
    {
        _reply = reply;
        _host = theHost;
        _shouldSendProfile = [self shouldAskAboutProfile];
        _systemProfileInformationArray = request.systemProfile;
        [self setShouldCascadeWindows:NO];
    }
    return self;
}

- (BOOL)shouldAskAboutProfile
{
    return [(NSNumber *)[self.host objectForInfoDictionaryKey:SUEnableSystemProfilingKey] boolValue];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [self.host bundlePath]]; }

- (void)windowDidLoad
{
    [self.window center];
    
    self.infoChoiceView.hidden = ![self shouldAskAboutProfile];
    
    [self.stackView addArrangedSubview:self.promptView];
    [self.stackView addArrangedSubview:self.infoChoiceView];
    [self.stackView addArrangedSubview:self.moreInfoView];
    [self.stackView addArrangedSubview:self.responseView];
}

- (BOOL)tableView:(NSTableView *) __unused tableView shouldSelectRow:(NSInteger) __unused row { return NO; }


- (NSImage *)icon
{
    return [SUApplicationInfo bestIconForHost:self.host];
}

- (NSString *)promptDescription
{
    return [NSString stringWithFormat:SULocalizedString(@"Should %1$@ automatically check for updates? You can always check for updates manually from the %1$@ menu.", nil), [self.host name]];
}

- (IBAction)toggleMoreInfo:(id)__unused sender
{
    self.moreInfoView.hidden = !self.moreInfoView.hidden;
}

- (IBAction)finishPrompt:(NSButton *)sender
{
    SUUpdatePermissionResponse *response = [[SUUpdatePermissionResponse alloc] initWithAutomaticUpdateChecks:([sender tag] == 1) sendSystemProfile:self.shouldSendProfile];
    self.reply(response);
    
    [self close];
}

- (NSTouchBar *)makeTouchBar
{
    NSTouchBar *touchBar = [(NSTouchBar *)[NSClassFromString(@"NSTouchBar") alloc] init];
    touchBar.defaultItemIdentifiers = @[SUUpdatePermissionPromptTouchBarIndentifier,];
    touchBar.principalItemIdentifier = SUUpdatePermissionPromptTouchBarIndentifier;
    touchBar.delegate = self;
    return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar * __unused)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier API_AVAILABLE(macos(10.12.2))
{
    if ([identifier isEqualToString:SUUpdatePermissionPromptTouchBarIndentifier]) {
        NSCustomTouchBarItem* item = [(NSCustomTouchBarItem *)[NSClassFromString(@"NSCustomTouchBarItem") alloc] initWithIdentifier:identifier];
        item.viewController = [[SUTouchBarButtonGroup alloc] initByReferencingButtons:@[self.checkButton, self.cancelButton]];
        return item;
    }
    return nil;
}

@end
