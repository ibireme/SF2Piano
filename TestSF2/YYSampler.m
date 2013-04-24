

#import "YYSampler.h"
#import <AssertMacros.h>

@interface YYSampler()
@property (nonatomic, assign) AUGraph AUGraph;
@property (nonatomic, assign) AudioUnit samplerUnit;
@end

@implementation YYSampler

- (id)init {
    self = [super init];
    if (self) {
        [self prepareAUGraph];
    }
    return self;
}

- (void)dealloc {
    AUGraphUninitialize(_AUGraph);
    AUGraphClose(_AUGraph);
    DisposeAUGraph(_AUGraph);
}


- (void)prepareAUGraph {
    OSStatus err;

    AUNode samplerNode;
    AUNode remoteOutputNode;

    NewAUGraph(&_AUGraph);
    AUGraphOpen(_AUGraph);

    AudioComponentDescription cd;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType =  kAudioUnitSubType_RemoteIO;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = cd.componentFlagsMask = 0;

    err = AUGraphAddNode(_AUGraph, &cd, &remoteOutputNode);
    if (err) {
        NSLog(@"err = %ld", err);
    }
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    err = AUGraphAddNode(_AUGraph, &cd, &samplerNode);
    if (err) {
        NSLog(@"err = %ld", err);
    }
    err = AUGraphConnectNodeInput(_AUGraph, samplerNode, 0, remoteOutputNode, 0);
    if (err) {
        NSLog(@"err = %ld", err);
    }

    err = AUGraphInitialize(_AUGraph);
    if (err) {
        NSLog(@"err = %ld", err);
    }
    err = AUGraphStart(_AUGraph);
    if (err) {
        NSLog(@"err = %ld", err);
    }

    err = AUGraphNodeInfo(_AUGraph,
                          samplerNode,
                          NULL,
                          &_samplerUnit);
    if (err) {
        NSLog(@"err = %ld", err);
    }
}

- (void)triggerNote:(NSUInteger)note {
    [self noteOn:@(note) velocity:@127];
    [self noteOn:@(note) velocity:@0];
}

- (void)triggerNote:(NSUInteger)note isOn:(BOOL)isOn {
    [self noteOn:@(note) velocity:isOn ? @127: @0];
}

- (void)noteOn:(NSNumber *)noteNumber velocity:(NSNumber *)velocityNumber {
    NSUInteger note = [noteNumber integerValue];
    NSUInteger velocity = [velocityNumber integerValue];
    MusicDeviceMIDIEvent(_samplerUnit,
                         0x90,
                         note,
                         velocity,
                         0);
}


- (OSStatus)loadFromDLSOrSoundFont:(NSURL *)bankURL withPatch:(int)presetNumber {
    OSStatus result = noErr;
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef)bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8)presetNumber;

    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(_samplerUnit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    // check for errors
    NSCAssert(result == noErr,
              @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
              (int)result,
              (const char *)&result);
    return result;
}

@end
