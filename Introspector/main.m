//
//  main.m
//  Introspector
//
//  Created by Moshe Berman on 1/30/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "InstrospectorApplication.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, NSStringFromClass([InstrospectorApplication class]), NSStringFromClass([AppDelegate class]));
    }
}
