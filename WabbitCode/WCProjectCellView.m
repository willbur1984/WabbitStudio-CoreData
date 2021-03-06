//
//  WCProjectCellView.m
//  WabbitStudio
//
//  Created by William Towe on 11/2/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectCellView.h"
#import "Project.h"
#import "File.h"
#import "WCDefines.h"

@interface WCProjectCellView () <NSTextFieldDelegate>

@property (readonly,nonatomic) File *file;

@end

@implementation WCProjectCellView

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    
    if (objectValue) {
        [self.textField setStringValue:self.file.name];
        [self.textField setToolTip:self.file.path];
        [self.imageView setImage:self.file.image];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if (control == self.textField)
        return (fieldEditor.string.length > 0);
    return YES;
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:)) {
        NSInteger numberOfRows = self.outlineView.numberOfRows;
        NSInteger row = [self.outlineView rowForItem:self.objectValue];
        
        if ((++row) >= numberOfRows)
            row = 0;
        
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self.outlineView editColumn:0 row:row withEvent:nil select:YES];
        
        return YES;
    }
    else if (commandSelector == @selector(insertBacktab:)) {
        NSInteger numberOfRows = self.outlineView.numberOfRows;
        NSInteger row = [self.outlineView rowForItem:self.objectValue];
        
        if ((--row) < 0)
            row = numberOfRows - 1;
        
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self.outlineView editColumn:0 row:row withEvent:nil select:YES];
        
        return YES;
    }
    return NO;
}

- (File *)file {
    return (File *)self.objectValue;
}

- (IBAction)_textFieldAction:(NSTextField *)sender {
    if (self.file.isGroupValue) {
        [self.file setName:sender.stringValue];
    }
}

@end
