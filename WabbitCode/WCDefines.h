//
//  WCDefines.h
//  WabbitStudio
//
//  Created by William Towe on 9/20/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#ifndef WabbitStudio_WCDefines_h
#define WabbitStudio_WCDefines_h

#ifdef __OBJC__

#ifdef DEBUG

#define WCLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define WCLog(...)

#endif

#define WCLogObject(objectToLog) WCLog(@"%@",objectToLog)
#define WCLogCGRect(rectToLog) WCLogObject(NSStringFromCGRect(rectToLog))
#define WCLogCGSize(sizeToLog) WCLogObject(NSStringFromCGSize(sizeToLog))
#define WCLogCGPoint(pointToLog) WCLogObject(NSStringFromCGPoint(pointToLog))
#define WCLogCGFloat(floatToLog) WCLog(@"%f",floatToLog)

#ifdef DEBUG

#define WCAssertLog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]

#else

#define WCAssertLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

#endif

#define WCAssert(condition, ...) do { if (!(condition)) { WCAssertLog(__VA_ARGS__); }} while(0)

#endif

#endif
