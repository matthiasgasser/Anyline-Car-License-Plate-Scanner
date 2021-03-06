//
//  ALBarcodeScanViewController.m
//  AnylineExamples
//
//  Created by Matthias Gasser on 22/04/15.
//  Copyright (c) 2015 9yards GmbH. All rights reserved.
//

#import "ALMultiformatBarcodeScanViewController.h"

#import <Anyline/Anyline.h>

// This is the license key for the examples project used to set up Aynline below
NSString * const kBarcodeScanLicenseKey = @"eyJzY29wZSI6WyJBTEwiXSwicGxhdGZvcm0iOlsiaU9TIiwiQW5kcm9pZCIsIldpbmRvd3MiXSwidmFsaWQiOiIyMDE2LTExLTAxIiwibWFqb3JWZXJzaW9uIjoiMyIsImlzQ29tbWVyY2lhbCI6ZmFsc2UsImlvc0lkZW50aWZpZXIiOlsiYXQuYW55bGluZS5BbnlsaW5lRXhhbXBsZXMiXSwiYW5kcm9pZElkZW50aWZpZXIiOlsiYXQuYW55bGluZS5BbnlsaW5lRXhhbXBsZXMiXSwid2luZG93c0lkZW50aWZpZXIiOlsiYXQuYW55bGluZS5BbnlsaW5lRXhhbXBsZXMiXX0KRWFBaXdNenRyZkxOZzJtNVd0bWpNTk9haGFqU1AwazVjLzJYcmlwVmV2NjFJdmF5cmdDMERENXk5ODdmenB1UkQ5ejNteEUyajY5cE1hNXJKMFhsMTFiSmNUbFFQRFltczJ2M0xCZC9xVVl0anJMbVNhcWtOREhXWi9uMXhSUWdsUDZjaHYwaEFNTDM4bjNrZk9WMnJqSWlhQWljZ0tBUElTZnNuUlFaUkovRTBBNk93aUxyVW5JNFp2MThieml5MG1KQ1NVLzJNakJOT1JjYnB2NE9WeXVpcmlPNGVuN0Q4K3E2UFFmR2FRNXlvREhLK1NyeFU2SzI0S016VVBzN3d2a0lCaWZzcGEzaXNzYXlRcDVucnpUemRlN3RyM2dha2JYeUVOSy9UL21ONjNnMlBDd3JzbU80NnY4R3FPLzZGMStZUDlhUVJpUWdmS0s0Ly8vemVRPT0=";
// The controller has to conform to <AnylineBarcodeModuleDelegate> to be able to receive results
@interface ALMultiformatBarcodeScanViewController() <AnylineBarcodeModuleDelegate>
// The Anyline module used to scan barcodes
@property (nonatomic, strong) AnylineBarcodeModuleView *barcodeModuleView;
// A debug label to show scanned results
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation ALMultiformatBarcodeScanViewController

/*
 We will do our main setup in viewDidLoad. Its called once the view controller is getting ready to be displayed.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the background color to black to have a nicer transition
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Barcode";
    
    // Initializing the barcode module. Its a UIView subclass. We set the frame to fill the whole screen
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame = CGRectMake(frame.origin.x, frame.origin.y + self.navigationController.navigationBar.frame.size.height, frame.size.width, frame.size.height - self.navigationController.navigationBar.frame.size.height);
    self.barcodeModuleView = [[AnylineBarcodeModuleView alloc] initWithFrame:frame];
    
    NSError *error = nil;
    // We tell the module to bootstrap itself with the license key and delegate. The delegate will later get called
    // by the module once we start receiving results.
    BOOL success = [self.barcodeModuleView setupWithLicenseKey:kBarcodeScanLicenseKey delegate:self error:&error];

    // setupWithLicenseKey:delegate:error returns true if everything went fine. In the case something wrong
    // we have to check the error object for the error message.
    if( !success ) {
        // Something went wrong. The error object contains the error description
        [[[UIAlertView alloc] initWithTitle:@"Setup Error"
                                    message:error.debugDescription
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    self.barcodeModuleView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // After setup is complete we add the module to the view of this view controller
    [self.view addSubview:self.barcodeModuleView];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moduleView]|" options:0 metrics:nil views:@{@"moduleView" : self.barcodeModuleView}]];
    
    id topGuide = self.topLayoutGuide;
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[moduleView]|" options:0 metrics:nil views:@{@"moduleView" : self.barcodeModuleView, @"topGuide" : topGuide}]];
    
    // The resultLabel is used as a debug view to see the scanned results. We set its text
    // in anylineBarcodeModuleView:didFindScanResult:atImage below
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50)];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.textColor = [UIColor whiteColor];
    self.resultLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35.0];
    self.resultLabel.adjustsFontSizeToFitWidth = YES;

    [self.view addSubview:self.resultLabel];
}

/*
 This method will be called once the view controller and its subviews have appeared on screen
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
     This is the place where we tell Anyline to start receiving and displaying images from the camera.
     Success/error tells us if everything went fine.
     */
    NSError *error;
    BOOL success = [self.barcodeModuleView startScanningAndReturnError:&error];
    if( !success ) {
        // Something went wrong. The error object contains the error description
        [[[UIAlertView alloc] initWithTitle:@"Start Scanning Error"
                                    message:error.debugDescription
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

/*
 Cancel scanning to allow the module to clean up
 */
- (void)viewWillDisappear:(BOOL)animated {
    [self.barcodeModuleView cancelScanningAndReturnError:nil];
}

#pragma mark -- AnylineBarcodeModuleDelegate
/*
 This is the main delegate method Anyline uses to report its scanned codes
 */
- (void)anylineBarcodeModuleView:(AnylineBarcodeModuleView *)anylineBarcodeModuleView
               didFindScanResult:(NSString *)scanResult
               withBarcodeFormat:(ALBarcodeFormat)barcodeFormat
                         atImage:(UIImage *)image  {
    // Because in this case scanResult is a simple string, we are able to forward it to the debug label
    self.resultLabel.text = scanResult;
}

@end
