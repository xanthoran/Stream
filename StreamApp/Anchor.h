//
//  AnchorViewController.h
//  StreamApps
//
//  Created by PETER LEACH on 1/16/14.
//  Copyright (c) 2014 PETER LEACH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Anchor : UIViewController

-(void)setAnchor:(PFObject *) anchor;

@property (nonatomic, strong) NSArray *rippleArray;


@end
