#import "NUAInstagramCell.h"
#import <Cephei/NSString+HBAdditions.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>

@interface HBLinkTableCell ()

- (BOOL)shouldShowIcon;

@end

@interface NUAInstagramCell () {
    NSURLSession *_session;
    dispatch_queue_t _processingQueue;
}

@end

@implementation NUAInstagramCell

#pragma mark - Helpers

+ (NSString *)_urlForUsername:(NSString *)user {
    // Because kirby does so
    user = user.hb_stringByEncodingQueryPercentEscapes;

    // wow, people still copy paste this code
    // Yes, yes I do
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]]) {
        // Has instagram app
        return [@"instagram://user?username=" stringByAppendingString:user];
    } else {
        return [@"https://instagram.com/" stringByAppendingString:user];
    }
}


#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        // Create defaults
        _processingQueue = dispatch_queue_create("com.shade.nougat.preferences.instagram-avatar-queue", DISPATCH_QUEUE_SERIAL);

        NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:defaultConfiguration];

        // Configure cell
        UIImageView *imageView = (UIImageView *)self.accessoryView;
        UIImage *baseImage = [UIImage imageNamed:@"instagram" inBundle:[NSBundle bundleForClass:self.class]];
        imageView.image = [baseImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imageView sizeToFit];

        _username = [specifier.properties[@"user"] copy];
        NSAssert(_username, @"User name not provided");

        specifier.properties[@"url"] = [self.class _urlForUsername:_username];

        self.detailTextLabel.text = [@"@" stringByAppendingString:_username];

        [self loadAvatarIfNeeded];
    }

    return self;
}


#pragma mark - Avatar

- (BOOL)shouldShowIcon {
	// HBLinkTableCell doesn’t want avatars by default, but we do. Override its check method so that
	// if showAvatar and showIcon are unset, we return YES.
	return self.specifier.properties[@"showAvatar"] || self.specifier.properties[@"showIcon"] ? [super shouldShowIcon] : YES;
}

- (void)loadAvatarIfNeeded {
    if (!self.username || self.iconImage) {
        // No username, or already has image
        return;
    }

    dispatch_async(_processingQueue, ^{
        NSString *username = self.username.hb_stringByEncodingQueryPercentEscapes;
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.instagram.com/%@/?__a=1", username]];

        // Retrieve data
        [self _loadDataFromURL:URL completion:^(NSData *data) {
            // Pass to helper method
            [self _parseInstagramData:data];
        }];
    });
}

- (void)_parseInstagramData:(NSData *)jsonData {
    if (!jsonData) {
        HBLogError(@"[Nougat] Error loading instagram avatar: no data from api");
        return;
    }

    dispatch_async(_processingQueue, ^{
        // Parse the json
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (![NSJSONSerialization isValidJSONObject:JSON] || error) {
            HBLogError(@"[Nougat] Error loading instagram avatar: %@", error);
            return;
        }

        NSDictionary *userData = JSON[@"graphql"][@"user"];
        if (!userData) {
            HBLogError(@"[Nougat] Error loading instagram avatar: no user data");
            return;
        }

        // Check if should load HD image
        NSString *profilePictureKey = [UIScreen mainScreen].scale > 2 ? @"profile_pic_url_hd" : @"profile_pic_url";
        NSString *avatarURL = userData[profilePictureKey];
        if (!avatarURL) {
            HBLogError(@"[Nougat] Error loading instagram avatar: no avatar url");
            return;
        }

        // URL stuff to get image
        NSURL *URL = [NSURL URLWithString:avatarURL];
        [self _loadDataFromURL:URL completion:^(NSData *data) {
            if (!data) {
                HBLogError(@"[Nougat] Error loading instagram avatar: no data from avatar url");
                return;
            }

            // Set image
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.iconImage = image;
            });
        }];
    });
}

#pragma mark - Networking Helpers

- (void)_loadDataFromURL:(NSURL *)URL completion:(void(^)(NSData *data))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [[_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            HBLogError(@"[Nougat] Error loading instagram avatar: %@", error);
            return;
        }

        // Check for response codes
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse && httpResponse.statusCode != 200) {
            // Error
            HBLogError(@"[Nougat] Error loading instagram avatar: status code not ok");
            return;
        }

        // Pass to completion
        completion(data);
    }] resume];
}

@end