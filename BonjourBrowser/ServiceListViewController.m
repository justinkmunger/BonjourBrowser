//
//  ServiceListViewController.m
//  BonjourBrowser
//
//  Created by Justin Munger on 3/16/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "ServiceListViewController.h"
#import "ServiceDetailViewController.h"

@implementation ServiceListViewController

@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize servicesArray = _servicesArray;
@synthesize selectedService = _selectedService;

#pragma mark -
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.servicesArray = [[NSMutableArray alloc] init];
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    
    NSString *browseType;
    if (self.selectedService == nil) {
        browseType = @"_services._dns-sd._udp.";
        self.title = @"Bonjour Browser";
    } else {
        NSString *fullDomainName = [NSString stringWithFormat:@"%@.%@", self.selectedService.name, self.selectedService.type];
        NSArray *domainNameParts = [fullDomainName componentsSeparatedByString:@"."];
        
        browseType = [NSString stringWithFormat:@"%@.%@.", [domainNameParts objectAtIndex:0], [domainNameParts objectAtIndex:1]];
        self.title = self.selectedService.name;
    }
    [self.netServiceBrowser searchForServicesOfType:browseType inDomain:@""];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Allow all orientations
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.netServiceBrowser.delegate = nil;
    [self.netServiceBrowser stop];
    self.netServiceBrowser  = nil;
}

- (void)dealloc
{
    self.netServiceBrowser = nil;
    self.servicesArray = nil;
    self.selectedService = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in each section of the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.servicesArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
        cell.textLabel.text = @"";
    }

    NSNetService *service = [self.servicesArray objectAtIndex:indexPath.row];
    if (self.selectedService == nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@.%@", service.name, service.type];
    } else {
        cell.textLabel.text = service.name;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - 
#pragma mark UITableViewDelegate methods
// Customize the font size for the text labels in each cell.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
}

// Customize the behavior for tapping a cell in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *service = [self.servicesArray objectAtIndex:indexPath.row];
    
    if (self.selectedService == nil) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        ServiceListViewController *slvc = [[ServiceListViewController alloc] initWithNibName:@"ServiceListViewController" bundle:nil];
        slvc.selectedService = service;
        [self.navigationController pushViewController:slvc animated:YES];
        [slvc release];
    } else {
        service.delegate = self;
        [service resolveWithTimeout:10.0];
    }
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate methods
-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
    self.netServiceBrowser.delegate = nil;
    [self.netServiceBrowser stop];
    self.netServiceBrowser = nil;   
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser { 
    self.netServiceBrowser.delegate = nil;
    self.netServiceBrowser = nil;
}
   
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.servicesArray addObject:aNetService];
    if (moreComing == NO) {
        [self.tableView reloadData];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [self.servicesArray sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        [sd release];
        
//        self.netServiceBrowser.delegate = nil;
//        [self.netServiceBrowser stop];
//        self.netServiceBrowser  = nil;
        NSRange stringRange = [self.title rangeOfString:@"Bonjour Browser"];
        if (stringRange.location == 0) {
            self.title = [NSString stringWithFormat:@"Bonjour Browser (%i)", [self.servicesArray count]];            
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing {
    for (int i = 0; i < self.servicesArray.count; i++) {
        if ([((NSNetService *)[self.servicesArray objectAtIndex:i]).name isEqualToString:netService.name]) {
            [self.servicesArray removeObjectAtIndex:i];
            break;
        }
    }
    if (moreComing == NO) {
        [self.tableView reloadData];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [self.servicesArray sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        [sd release];
        
        NSRange stringRange = [self.title rangeOfString:@"Bonjour Browser"];
        if (stringRange.location == 0) {
            self.title = [NSString stringWithFormat:@"Bonjour Browser (%i)", [self.servicesArray count]];                    
        }
    }
}

#pragma mark -
#pragma mark NSNetServiceDelegate methods
-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSNumber *errorCode = [errorDict valueForKey:NSNetServicesErrorCode];
    
    NSString *errorMessage;
    switch ([errorCode intValue]) {
        case NSNetServicesActivityInProgress:
            errorMessage = @"Service Resolution Currently in Progress. Please Wait.";
            break;
        case NSNetServicesTimeoutError:
            errorMessage = @"Service Resolution Timeout";
            [sender stop];
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bonjour Browser" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)netServiceDidResolveAddress:(NSNetService *)service {
    ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithNibName:@"ServiceDetailViewController" bundle:nil];
    sdvc.selectedService = service;
    
    [self.navigationController pushViewController:sdvc animated:YES];
    [sdvc release];
}
@end
