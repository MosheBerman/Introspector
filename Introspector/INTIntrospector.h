//
//  INTIntrospector.h
//  Introspector
//
//  Created by Moshe Berman on 1/31/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INTIntrospector : NSObject

- (NSArray *)subclassesOfClass:(Class)targetClass;
- (NSArray *)methodsFromClass:(Class)targetClass;
- (NSDictionary *)propertiesOfClass:(Class)targetClass;

@end
