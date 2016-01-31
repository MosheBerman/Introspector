//
//  INTIntrospector.m
//  Introspector
//
//  Created by Moshe Berman on 1/31/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import "INTIntrospector.h"
@import ObjectiveC;

@implementation INTIntrospector


- (NSArray *)subclassesOfClass:(Class)targetClass
{
    return [ClassGetSubclasses(targetClass) sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        Class class1 = obj1;
        Class class2 = obj2;
        
        NSString *name1 = NSStringFromClass(class1);
        NSString *name2 = NSStringFromClass(class2);
        
        return [name1 compare:name2];
    }];
}
- (NSArray *)methodsFromClass:(Class)targetClass
{
    return ClassGetMethods(targetClass);
}

- (NSDictionary *)propertiesOfClass:(Class)targetClass
{
    return classPropsForClass(targetClass);
}

// This method taken from: http://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
NSArray *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    
    classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do
        {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil)
        {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}


// http://stackoverflow.com/a/27073297/224988
NSArray* ClassGetMethods(Class targetClass) {
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(targetClass, &methodCount);
    
    printf("Found %d methods on '%s'\n", methodCount, class_getName(targetClass));
    
    NSMutableArray <NSString *> * methodNames = [NSMutableArray array];
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        //        printf("\t'%s' has method named '%s' of encoding '%s'\n", class_getName(targetClass), sel_getName(method_getName(method)), method_getTypeEncoding(method));
        
        /**
         *  Or do whatever you need here...
         */
        const char * mName = sel_getName(method_getName(method));
        
        [methodNames addObject:[NSString stringWithUTF8String:mName]];
    }
    
    free(methods);
    
    return methodNames;
}

// The next two methods modified from: http://stackoverflow.com/a/8380836/224988

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    
    NSString *attributesString = propertyAttributesFromCString(attributes);
    
    return [attributesString cStringUsingEncoding:NSUTF8StringEncoding];
}


NSDictionary * classPropsForClass(Class targetClass)
{
    if (targetClass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(targetClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = propertyAttributesFromCString(propType);
            if(propertyName && propertyType)
            {
                [results setObject:propertyType forKey:propertyName];
            }
            
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

#pragma mark - Helpers

/**
 *  Converts an attributes string to a readable description of a property.
 */

NSString * propertyAttributesFromCString(const char * string)
{
    NSMutableString *output = [[NSMutableString alloc] init];
    
    NSString *utf8 = [NSString stringWithUTF8String:string];
    
    NSArray *components = [utf8 componentsSeparatedByString:@","];
    NSCharacterSet *atAndQuotesSet = [NSCharacterSet characterSetWithCharactersInString:@"@\""];
    
    for (NSString *component in components)
    {
        if (output.length > 0)
        {
            [output appendString:@", "];
        }
        
        // Known types
        if (component.length > 3 && [component characterAtIndex:0] == 'T')
        {
            NSString *type = [[component componentsSeparatedByCharactersInSet:atAndQuotesSet] componentsJoinedByString:@""]; // Remove @"" wrapper
            type = [type substringFromIndex:1]; // Remove leading T
            [output appendString:type];
        }
        else if (component.length == 3 && [component characterAtIndex:0] == 'T')
        {
            if ([component characterAtIndex:1] == 'b')
            {
                [output appendString:@"bitfield (length "];
                [output appendFormat:@"%c",[component characterAtIndex:2]];
                [output appendString:@")"];
            }
            else if ([component characterAtIndex:1] == '^')
            {
                NSString *string = [component substringFromIndex:2];
                NSString *type = typeForEncodingValue(string);
                if (type != nil)
                {
                    [output appendString:type];
                    [output appendString:@" *"];
                }
                else
                {
                    [output appendString:component];
                }
            }
        }
        else if (typeForEncodingValue(component) != nil)
        {
            [output appendString:typeForEncodingValue(component)];
        }
        else if (descriptionForEncodingValue(component) != nil)
        {
            [output appendString:descriptionForEncodingValue(component)];
        }
        // Custom Setter
        else if ([component characterAtIndex:0] == 'S')
        {
            [output appendString:@"setter: "];
            [output appendString:[component substringFromIndex:1]];
        }
        // Custom Getter
        else if ([component characterAtIndex:0] == 'G')
        {
            [output appendString:@"getter: "];
            [output appendString:[component substringFromIndex:1]];
        }
        else if ([component characterAtIndex:0] == 'V' && output.length > 0)
        {
            // Don't append backing ivar name.
        }
        else
        {
            [output appendString:component];
        }
        
    }
    
    return output;
}

NSString *descriptionForEncodingValue(NSString *value) {
    static NSDictionary *mapping = nil;
  
  if (mapping == nil)
  {
      mapping = @{
                  @"R" : @"readonly",
                  @"C" : @"copy",
                  @"&" : @"retain",
                  @"N" : @"nonatomic",
                  @"D" : @"dynamic",
                  @"W" : @"weak",
                  @"P" : @"garbage collected",
                  };
  }
    return mapping[value];
}

NSString *typeForEncodingValue(NSString *value) {
    
    // If not a type, we can't key in.
    if ([value characterAtIndex:0] != 'T')
    {
        return nil;
    }
    
    static NSDictionary *mapping = nil;
    
    if (mapping == nil)
    {
        mapping = @{
                    @"B" : @"bool",
                    @"c" : @"char",
                    @"d" : @"double",
                    @"f" : @"float",
                    @"i" : @"int",
                    @"l" : @"long",
                    @"q" : @"long long",
                    @"s" : @"short",
                    @"v" : @"void",
                    @"*" : @"char *",
                    @"@" : @"id", // ObjC id type
                    @"#" : @"class",
                    @":" : @"SEL",
                    @"C" : @"unsigned char",
                    @"I" : @"unsigned int",
                    @"L" : @"unsigned long",
                    @"Q" : @"unsigned long long"
                    };
    }
    
    NSString *key = [value substringFromIndex:1]; // Remove leading T.
    return mapping[key];
    
    
}

@end
