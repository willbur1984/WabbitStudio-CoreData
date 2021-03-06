//
//  WCGeometry.h
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#ifndef WabbitStudio_WCGeometry_h
#define WabbitStudio_WCGeometry_h

#ifdef __OBJC__

#import <Foundation/NSGeometry.h>

static inline NSRect WC_NSRectCenter(NSRect rectToCenter, NSRect inRect) {
    return NSIntegralRectWithOptions(NSMakeRect(NSMinX(inRect) + (NSWidth(inRect) * 0.5) - (NSWidth(rectToCenter) * 0.5), NSMinY(inRect) + (NSHeight(inRect) * 0.5) - (NSHeight(rectToCenter) * 0.5), NSWidth(rectToCenter), NSHeight(rectToCenter)),NSAlignAllEdgesInward);
}

static inline NSRect WC_NSRectCenterWithSize(NSSize sizeToCenter, NSRect inRect) {
    return WC_NSRectCenter(NSMakeRect(0, 0, sizeToCenter.width, sizeToCenter.height), inRect);
}

static inline NSRect WC_NSRectCenterX(NSRect rectToCenter, NSRect inRect) {
    NSRect retval = WC_NSRectCenter(rectToCenter, inRect);
    
    retval.origin.y = rectToCenter.origin.y;
    
    return retval;
}

static inline NSRect WC_NSRectCenterY(NSRect rectToCenter, NSRect inRect) {
    NSRect retval = WC_NSRectCenter(rectToCenter, inRect);
    
    retval.origin.x = rectToCenter.origin.x;
    
    return retval;
}

static inline BOOL WC_NSLocationInOrEqualToRange(NSUInteger loc, NSRange range) {
	return (loc - range.location <= range.length);
}

static const NSSize WC_NSSmallSize = {16,16};
static const NSSize WC_NSMediumSize = {24,24};

static const NSRange WC_NSNotFoundRange = {NSNotFound,0};
static const NSRange WC_NSEmptyRange = {0,0};

#endif

#endif
