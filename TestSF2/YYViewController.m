
#import "YYViewController.h"
#import "YYSampler.h"


NSString *patchNames = @"0=Stereo Grand|\
1=Bright Grand|\
2=Electric Grand|\
3=Honky-Tonk|\
4=Tine Electric Piano|\
5=FM Electric Piano|\
6=Harpsichord|\
7=Clavinet|\
8=Celeste|\
9=Glockenspiel|\
10=Music Box|\
11=Vibraphone|\
12=Marimba|\
13=Xylophone|\
14=Tubular Bells|\
15=Dulcimer|\
16=Tonewheel Organ|\
17=Percussive Organ|\
18=Rock Organ|\
19=Pipe Organ|\
20=Reed Organ|\
21=Accordian|\
22=Harmonica|\
23=Bandoneon|\
24=Nylon Guitar|\
25=Steel Guitar|\
26=Jazz Guitar|\
27=Clean Guitar|\
28=Muted Guitar|\
29=Overdrive Guitar|\
30=Distortion Guitar|\
31=Guitar Harmonics|\
32=Acoustic Bass|\
33=Finger Bass|\
34=Pick Bass|\
35=Fretless Bass|\
36=Slap Bass 1|\
37=Slap Bass 2|\
38=Synth Bass 1|\
39=Synth Bass 2|\
40=Violin|\
41=Viola|\
42=Cello|\
43=Double Bass|\
44=St. Trem. Strings|\
45=Pizzicato Strings|\
46=Orchestral Harp|\
47=Timpani|\
48=St. Strings Fast|\
49=St. Strings Slow|\
50=Synth Strings 1|\
51=Synth Strings 2|\
52=Concert Choir|\
53=Voice Oohs|\
54=Synth Voice|\
55=Orchestra Hit|\
56=Trumpet|\
57=Trombone|\
58=Tuba|\
59=Muted Trumpet|\
60=French Horns|\
61=Brass Section|\
62=Synth Brass 1|\
63=Synth Brass 2|\
64=Soprano Sax|\
65=Alto Sax|\
66=Tenor Sax|\
67=Baritone Sax|\
68=Oboe|\
69=English Horn|\
70=Bassoon|\
71=Clarinet|\
72=Piccolo|\
73=Flute|\
74=Recorder|\
75=Pan Flute|\
76=Bottle Blow|\
77=Shakuhachi|\
78=Irish Tin Whistle|\
79=Ocarina|\
80=Square Lead|\
81=Saw Lead|\
82=Synth Calliope|\
83=Chiffer Lead|\
84=Charang|\
85=Solo Vox|\
86=5th Saw Wave|\
87=Bass & Lead|\
88=Fantasia|\
89=Warm Pad|\
90=Polysynth|\
91=Space Voice|\
92=Bowed Glass|\
93=Metal Pad|\
94=Halo Pad|\
95=Sweep Pad|\
96=Ice Rain|\
97=Soundtrack|\
98=Crystal|\
99=Atmosphere|\
100=Brightness|\
101=Goblin|\
102=Echo Drops|\
103=Star Theme|\
104=Sitar|\
105=Banjo|\
106=Shamisen|\
107=Koto|\
108=Kalimba|\
109=Bagpipes|\
110=Fiddle|\
111=Shenai|\
112=Tinker Bell|\
113=Agogo|\
114=Steel Drums|\
115=Wood Block|\
116=Taiko Drum|\
117=Melodic Tom|\
118=Synth Drum|\
119=Reverse Cymbal|\
120=Fret Noise|\
121=Breath Noise|\
122=Seashore|\
123=Birds|\
124=Telephone 1|\
125=Helicopter|\
126=Applause|\
127=Gun Shot";

@interface YYViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) NSArray *patchs;
@end

@implementation YYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generateButtons];
    
    
    
    self.patchs = [patchNames componentsSeparatedByString:@"|"];
    self.sampler = [[YYSampler alloc] init];
    [self loadSamplerPath:2];
    
    [_samplerTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                   animated:NO scrollPosition:UITableViewScrollPositionTop];
    CGRect rect = _kbdScrollView.bounds;
    rect.origin.x = 1200;
    [_kbdScrollView scrollRectToVisible:rect animated:NO];
}


- (void)loadSamplerPath:(int)pathId {
    NSURL *presetURL;
    presetURL = [[NSBundle mainBundle] URLForResource:@"GeneralUser GS SoftSynth v1.44"
                                        withExtension:@"sf2"];
    [_sampler loadFromDLSOrSoundFont:presetURL withPatch:pathId];
}



- (void)generateButtons {
    int whiteWidth = 56;
    int whiteHeight = 400;
    int blackWidth = 40;
    int blackHeight = 270;

    // Middle C is 60 (MIDI note C4)
    int startNote = 21;
    int totalNote = 88; //total 88 keyboards

    NSMutableArray *whiteBtns = [NSMutableArray array];
    NSMutableArray *blackBtns = [NSMutableArray array];

    for (int note = startNote; note < startNote + totalNote; note++) {
        int octave = note / 12 - 1;
        int indexInOctave = note % 12;
        int indexKbdInOctave = -1;
        BOOL isWhite = YES;
        switch (indexInOctave) {
            case 0: case 2: case 4: case 5: case 7: case 9: case 11:
                indexKbdInOctave = (indexInOctave + 1) / 2;
                break;
            default:
                indexKbdInOctave = indexInOctave / 2;
                isWhite = NO;
        }

        //keyboard offset
        int x = (octave * 7 + indexKbdInOctave - 5) * whiteWidth + (isWhite ? 0 : whiteWidth - blackWidth / 2);
        CGRect rect = CGRectMake(x, 350, isWhite ? whiteWidth : blackWidth, isWhite ? whiteHeight : blackHeight);
        UIButton *btn = [self getBtn:rect isWhite:isWhite tag:note];
        [isWhite ? whiteBtns : blackBtns addObject:btn];
    }

    for (UIButton *btn in whiteBtns) {
        [_kbdScrollView addSubview:btn];
    }
    for (UIButton *btn in blackBtns) {
        [_kbdScrollView addSubview:btn];
    }

    _kbdScrollView.contentSize = CGSizeMake(((UIButton *)whiteBtns.lastObject).frame.origin.x + whiteWidth, _kbdScrollView.frame.size.height);
}

- (UIButton *)getBtn:(CGRect)rect isWhite:(BOOL)isWhite tag:(int)tag {
    UIButton *btn;
    if (!isWhite) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[self getImageFromColor:[UIColor blackColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[self getImageFromColor:[UIColor colorWithWhite:0.2 alpha:1]] forState:UIControlStateHighlighted];
    } else {
        btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setBackgroundImage:[self getImageFromColor:[UIColor colorWithWhite:0.8 alpha:1]] forState:UIControlStateHighlighted];
    }
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.frame = rect;
    btn.tag = tag;
    [btn addTarget:self action:@selector(triggleOn:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(triggleOff:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(triggleOff:) forControlEvents:UIControlEventTouchCancel];
    [btn addTarget:self action:@selector(triggleOff:) forControlEvents:UIControlEventTouchDragOutside];
    return btn;
}

- (void)triggleOn:(UIButton *)btn {
    [_sampler triggerNote:btn.tag isOn:YES];
}

- (void)triggleOff:(UIButton *)btn {
    [_sampler triggerNote:btn.tag isOn:NO];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 128;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:SectionsTableIdentifier ];
    }

    cell.textLabel.text = [_patchs objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self loadSamplerPath:indexPath.row];
}


- (UIImage *)getImageFromColor:(UIColor *)color {
    CGSize imageSize = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}



@end
