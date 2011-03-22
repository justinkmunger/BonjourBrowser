//
//  ServiceDetailViewController.h
//  BonjourBrowser
//
//  Created by Justin Munger on 3/19/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ServiceDetailViewController : UITableViewController {
    NSNetService *_selectedService;
    NSDictionary *_serviceTXTRecords;
}

@property (nonatomic, retain) NSNetService *selectedService;

@end
