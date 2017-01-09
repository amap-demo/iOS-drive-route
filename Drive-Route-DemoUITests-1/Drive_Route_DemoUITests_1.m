//
//  Drive_Route_DemoUITests_1.m
//  Drive-Route-DemoUITests-1
//
//  Created by eidan on 17/1/9.
//  Copyright © 2017年 autonavi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Drive_Route_DemoUITests_1 : XCTestCase

@end

@implementation Drive_Route_DemoUITests_1

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    sleep(2);
    
    [app.switches[@"1"] tap];
    
    sleep(1);
    
    [app.switches[@"0"] tap];
    
    XCUIElement *button = app.buttons[@"\u4e0b\u4e00\u8def\u7ebf"];
    [button tap];
    sleep(1);
    
    [button tap];
    sleep(1);
    
    [app.buttons[@"\u8def\u7ebf\u8be6\u60c5"] tap];
    
    XCUIElement *tablesQuery = app.tables.element;
    [tablesQuery swipeUp];
    
    [tablesQuery swipeDown];
    
    [app.buttons[@"public button back"] tap];
    
    // wait
    XCTestExpectation *e = [self expectationWithDescription:@"empty wait"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [e fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
