//
//  ServiceListViewController.h
//  BonjourBrowser
//
//  Created by Justin Munger on 3/16/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceListViewController : UITableViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSNetServiceBrowser *_netServiceBrowser;
    NSMutableArray *_servicesArray;
    NSNetService *_selectedService;
}

@property (nonatomic, retain) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, retain) NSMutableArray *servicesArray;
@property (nonatomic, retain) NSNetService *selectedService;

@end

