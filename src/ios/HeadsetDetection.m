#import "HeadsetDetection.h"

@implementation HeadsetDetection

- (void) pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)routeChanged:(NSNotification *)notification {
    NSNumber *reason = [notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    if ([reason unsignedIntegerValue] == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
      if([self isHeadsetEnabled]){
        [self.commandDelegate evalJs:@"cordova.require('cordova-plugin-headsetdetection.HeadsetDetection').remoteHeadsetAdded()"];
      }
    } else if ([reason unsignedIntegerValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        [self.commandDelegate evalJs:@"cordova.require('cordova-plugin-headsetdetection.HeadsetDetection').remoteHeadsetRemoved()"];
    }
}

- (void) detect:(CDVInvokedUrlCommand*)command {
  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self isHeadsetEnabled]];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) registerRemoteEvents:(CDVInvokedUrlCommand*)command {
  // no implementation needed
}

- (BOOL) isHeadsetEnabled {
  AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
  for (AVAudioSessionPortDescription* desc in [route outputs]) {
      //Refer https://developer.apple.com/documentation/avfaudio/avaudiosessionport
    if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
      // [[desc portType] isEqualToString:AVAudioSessionPortUSBAudio] ||
      // [[desc portType] isEqualToString:AVAudioSessionPortBluetoothHFP] ||
      // [[desc portType] isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
      // [[desc portType] isEqualToString:AVAudioSessionPortBluetoothLE]
      return YES;
    }
  }
  return NO;
}

@end
