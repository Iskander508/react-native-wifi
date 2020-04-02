#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR
#import "RNWifi.h"
@implementation WifiManager
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(connectToSSID:(NSString*)ssid
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    reject(@"ios_error", @"Not supported on simulator", nil);
}

RCT_EXPORT_METHOD(connectToProtectedSSID:(NSString*)ssid
                  withPassphrase:(NSString*)passphrase
                  isWEP:(BOOL)isWEP
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    reject(@"ios_error", @"Not supported on simulator", nil);
}

RCT_EXPORT_METHOD(disconnectFromSSID:(NSString*)ssid
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    reject(@"ios_error", @"Not supported on simulator", nil);
}

RCT_REMAP_METHOD(getCurrentWifiSSID,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {

    reject(@"ios_error", @"Not supported on simulator", nil);
}
@end
#else
#import "RNWifi.h"
#import <SystemConfiguration/CaptiveNetwork.h>
// If using official settings URL
//#import <UIKit/UIKit.h>
#import <NetworkExtension/NetworkExtension.h>




@implementation WifiManager
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(connectToSSID:(NSString*)ssid
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    if (@available(iOS 11.0, *)) {
        NEHotspotConfiguration* configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid];
        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                if (error.code == NEHotspotConfigurationErrorUserDenied) {
                    reject(@"nehotspot_error", @"USER_DENIED", error);
                } else {
                    reject(@"nehotspot_error", @"Error while configuring WiFi", error);
                }
            } else {
                resolve(nil);
            }
        }];

    } else {
        reject(@"ios_error", @"Not supported in iOS<11.0", nil);
    }
}

RCT_EXPORT_METHOD(connectToProtectedSSID:(NSString*)ssid
                  withPassphrase:(NSString*)passphrase
                  isWEP:(BOOL)isWEP
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    if (@available(iOS 11.0, *)) {
        NEHotspotConfiguration* configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid passphrase:passphrase isWEP:isWEP];
        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                if (error.code == NEHotspotConfigurationErrorUserDenied) {
                    reject(@"nehotspot_error", @"USER_DENIED", error);
                } else {
                    reject(@"nehotspot_error", @"Error while configuring WiFi", error);
                }
            } else {
                resolve(nil);
            }
        }];

    } else {
        reject(@"ios_error", @"Not supported in iOS<11.0", nil);
    }
}

RCT_EXPORT_METHOD(disconnectFromSSID:(NSString*)ssid
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    if (@available(iOS 11.0, *)) {
        [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> *ssids) {
            if (ssids != nil && [ssids indexOfObject:ssid] != NSNotFound) {
                [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:ssid];
            }
            resolve(nil);
        }];
    } else {
        reject(@"ios_error", @"Not supported in iOS<11.0", nil);
    }

}

RCT_REMAP_METHOD(getCurrentWifiSSID,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {

    NSString *kSSID = (NSString*) kCNNetworkInfoKeySSID;

    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[kSSID]) {
            resolve(info[kSSID]);
            return;
        }
    }

    reject(@"cannot_detect_ssid", @"Cannot detect SSID", nil);
}
@end

#endif
