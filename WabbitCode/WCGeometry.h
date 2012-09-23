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

static const NSSize WC_NSSmallSize = {16,16};
static const NSSize WC_NSMediumSize = {24,24};

#endif

#endif
