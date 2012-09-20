//
//  WCDefines.h
//  WabbitStudio
//
//  Created by William Towe on 9/20/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

#define WCLogNSRect(rectToLog) WCLogObject(NSStringFromRect(rectToLog))
#define WCLogNSPoint(pointToLog) WCLogObject(NSStringFromPoint(pointToLog))

#ifdef DEBUG

#define WCAssertLog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]

#else

#define WCAssertLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

#endif

#define WCAssert(condition, ...) do { if (!(condition)) { WCAssertLog(__VA_ARGS__); }} while(0)

#endif

#endif
