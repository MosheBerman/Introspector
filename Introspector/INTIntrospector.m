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
        
        printf("\t'%s' has method named '%s' of encoding '%s'\n",
               class_getName(targetClass),
               sel_getName(method_getName(method)),
               method_getTypeEncoding(method));
        
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
    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
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
            NSString *propertyType = [NSString stringWithUTF8String:propType];
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

@end
