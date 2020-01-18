//
//  ViewController.m
//  NewMayurPaymentGatewayTest
//
//  Created by MAC2 on 10/3/18.
//  Copyright © 2018 MAC2. All rights reserved.
//

#import "ViewController.h"
#import "PUUIPaymentOptionVC.h"
#import "PUSAHelperClass.h"
#import "iOSDefaultActivityIndicator.h"



static NSString * const verifyAPIStoryBoard = @"PUVAMainStoryBoard";
static NSString * const pUUIStoryBoard = @"PUUIMainStoryBoard";

@interface ViewController ()

@property (strong, nonatomic) iOSDefaultActivityIndicator *defaultActivityIndicator;
@property (strong, nonatomic) PayUWebServiceResponse *webServiceResponse;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initialSetup];
    [self dismissKeyboardOnTapOutsideTextField];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self addKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    [self removeKeyboardNotifications];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initialSetup{
    self.defaultActivityIndicator = [iOSDefaultActivityIndicator new];
    self.paymentParam = [PayUModelPaymentParams new];
    
    //    self.paymentParam.key = @"0MQaQP";//@"gtKFFx";//@"0MQaQP";
    self.paymentParam.key = @"MAYUR";
    //self.paymentParam.transactionID = @"txnID123456";
    self.paymentParam.amount = @"10";
    self.paymentParam.productInfo = @"iPhone";
    self.paymentParam.SURL = @"https://payu.herokuapp.com/ios_success";
    self.paymentParam.FURL = @"https://payu.herokuapp.com/ios_failure";
    self.paymentParam.firstName = @"Baalak";
    self.paymentParam.email = @"Baalak@gmail.com";
    self.paymentParam.udf1 = @"";
    self.paymentParam.udf2 = @"";
    self.paymentParam.udf3 = @"";
    self.paymentParam.udf4 = @"";
    self.paymentParam.udf5 = @"";
    //    self.paymentParam.environment = ENVIRONMENT_PRODUCTION;
    [self setEnvironment:ENVIRONMENT_TEST];
    //[self setSalt:@"eCwWELxi"];
    self.paymentParam.offerKey = @""; //bins@8427,srioffer@8428,cc2@8429,gtkffx@7236,test123@6622
    self.paymentParam.userCredentials = @"gtKFFx:Baalak@gmail.com";
    self.paymentParam.subventionAmount = nil;
    self.paymentParam.subventionEligibility = nil;
    self.paymentParam.offerKey = nil;
    
    [self addPaymentResponseNotofication];
}

- (void)setEnvironment:(NSString*)env {
    self.paymentParam.environment = env;
    //    if ([env isEqualToString:ENVIRONMENT_PRODUCTION]) {
    //        self.paymentParam.key = @"0MQaQP";
    //    } else {
    //        self.paymentParam.key = @"6Te2QS";
    //    }
}



-(void)addPaymentResponseNotofication{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseReceived:) name:kPUUINotiPaymentResponse object:nil];
}

-(void)responseReceived:(NSNotification *) notification{
    [self.navigationController popToRootViewControllerAnimated:NO];
    //    self.textFieldTransactionID.text = [PUSAHelperClass getTransactionIDWithLength:15];
    NSString *strConvertedRespone = [NSString stringWithFormat:@"%@",notification.object];
    NSLog(@"Response Received %@",strConvertedRespone);
    
    NSError *serializationError;
    id JSON = [NSJSONSerialization JSONObjectWithData:[strConvertedRespone dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&serializationError];
    if (serializationError == nil && notification.object) {
        NSLog(@"%@",JSON);
        PAYUALERT([JSON objectForKey:@"status"], strConvertedRespone);
        if ([[JSON objectForKey:@"status"] isEqual:@"success"]) {
            NSString *merchant_hash = [JSON objectForKey:@"merchant_hash"];
            if ([[JSON objectForKey:@"card_token"] length] >1 && merchant_hash.length >1 && self.paymentParam) {
                NSLog(@"Saving merchant hash---->");
                [PUSAHelperClass saveOneTapTokenForMerchantKey:self.paymentParam.key withCardToken:[JSON objectForKey:@"card_token"] withUserCredential:self.paymentParam.userCredentials andMerchantHash:merchant_hash withCompletionBlock:^(NSString *message, NSString *errorString) {
                    if (errorString == nil) {
                        NSLog(@"Merchant Hash saved succesfully %@",message);
                    }
                    else{
                        NSLog(@"Error while saving merchant hash %@", errorString);
                    }
                }];
            }
        }
    }
    else{
        PAYUALERT(@"Response", strConvertedRespone);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) generateUniuqeTransactionID: (int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *transID = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [transID appendFormat:@"%C",[letters characterAtIndex:arc4random_uniform([letters length])]];
    }
    return transID;
}

-(void)setPaymentParamAndStartProcess{
    
    //    [self setSubventionParamter];
    //    [self setOfferKey];
    
    [self dismissKeyboard];
    [self.defaultActivityIndicator startAnimatingActivityIndicatorWithSelfView:self.view];
    self.view.userInteractionEnabled = NO;
    
    //    if (self.switchForSalt.on) {
    PayUDontUseThisClass *obj = [PayUDontUseThisClass new];
    [obj getPayUHashesWithPaymentParam:self.paymentParam merchantSalt:@"MAYUR" withCompletionBlock:^(PayUModelHashes *allHashes, PayUModelHashes *hashString, NSString *errorMessage) {
        [self callSDKWithHashes:allHashes withError:errorMessage];
    }];
    //    }
    //    else{
    //        [PUSAHelperClass generateHashFromServer:self.paymentParam withCompletionBlock:^(PayUModelHashes *hashes, NSString *errorString) {
    //            [self callSDKWithHashes:hashes withError:errorString];
    //        }];
    //
    //    }
}

-(void)callSDKWithHashes:(PayUModelHashes *) allHashes withError:(NSString *) errorMessage{
    if (errorMessage == nil) {
        self.paymentParam.hashes = allHashes;
        ////        if (self.switchForOneTap.on) {
        //            [PUSAHelperClass getOneTapTokenDictionaryFromServerWithPaymentParam:self.paymentParam CompletionBlock:^(NSDictionary *CardTokenAndOneTapToken, NSString *errorString) {
        //                if (errorMessage) {
        //                    [self.defaultActivityIndicator stopAnimatingActivityIndicator];
        //                    PAYUALERT(@"Error", errorMessage);
        //                }
        //                else{
        //                    [self callSDKWithOneTap:CardTokenAndOneTapToken];
        //                }
        //            }];
        //        }
        //        else{
        [self callSDKWithOneTap:nil];
        //        }
    }
    else{
        [self.defaultActivityIndicator stopAnimatingActivityIndicator];
        PAYUALERT(@"Error", errorMessage);
    }
}

-(void) callSDKWithOneTap:(NSDictionary *)oneTapDict{
    
    self.paymentParam.OneTapTokenDictionary = oneTapDict;
    PayUWebServiceResponse *respo = [PayUWebServiceResponse new];
    self.webServiceResponse = [PayUWebServiceResponse new];
    [self.webServiceResponse getPayUPaymentRelatedDetailForMobileSDK:self.paymentParam withCompletionBlock:^(PayUModelPaymentRelatedDetail *paymentRelatedDetails, NSString *errorMessage, id extraParam) {
        [self.defaultActivityIndicator stopAnimatingActivityIndicator];
        if (errorMessage) {
            PAYUALERT(@"Error", errorMessage);
        }
        else
        {
            //            if (_isStartBtnTapped) {
            [respo callVASForMobileSDKWithPaymentParam:self.paymentParam];        //FORVAS
            UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:pUUIStoryBoard bundle:nil];
            PUUIPaymentOptionVC * paymentOptionVC = [stryBrd instantiateViewControllerWithIdentifier:VC_IDENTIFIER_PAYMENT_OPTION];
            paymentOptionVC.paymentParam = self.paymentParam;
            paymentOptionVC.paymentRelatedDetail = paymentRelatedDetails;
            //                _isStartBtnTapped = FALSE;
            [self.navigationController pushViewController:paymentOptionVC animated:true];
            //  [self presentViewController:paymentOptionVC animated:YES completion:nil];
            //            }
            //            else if (_isVerifyAPIBtnTapped){
            //                if (self.switchForSalt.on) {
            //                    UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:verifyAPIStoryBoard bundle:nil];
            //                    PUVAOptionsVC *verifyAPIOptionsTVC = [stryBrd instantiateViewControllerWithIdentifier:NSStringFromClass([PUVAOptionsVC class])];
            //                    verifyAPIOptionsTVC.paymentParam = [PayUModelPaymentParams new];
            //                    verifyAPIOptionsTVC.paymentParam.key = self.paymentParam.key;
            //                    verifyAPIOptionsTVC.paymentParam.environment = self.paymentParam.environment;
            //                    verifyAPIOptionsTVC.paymentParam.userCredentials = self.paymentParam.userCredentials;
            //                    verifyAPIOptionsTVC.paymentParam.hashes.VASForMobileSDKHash = self.paymentParam.hashes.VASForMobileSDKHash;
            //                    verifyAPIOptionsTVC.paymentRelatedDetail = paymentRelatedDetails;
            //                    verifyAPIOptionsTVC.salt = self.textFieldSalt.text;
            //                    _isVerifyAPIBtnTapped = FALSE;
            //                    [respo callVASForMobileSDKWithPaymentParam:verifyAPIOptionsTVC.paymentParam];        //FORVAS
            //                    [self.navigationController pushViewController:verifyAPIOptionsTVC animated:true];
            //
            //                }
            //                else{
            //                    PAYUALERT(@"Error", @"For Verify API Salt is mandatory field");
            //                }
        }
        //        }
    }];
}
- (IBAction)btnStart:(id)sender {
    NSString *myTransID = [self generateUniuqeTransactionID:15];
    self.paymentParam.transactionID = myTransID;
    [self setPaymentParamAndStartProcess];
}




@end
