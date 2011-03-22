//
//  ServiceDetailViewController.m
//  BonjourBrowser
//
//  Created by Justin Munger on 3/19/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "ServiceDetailViewController.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>


@interface ServiceDetailViewController () 

@property (nonatomic, retain) NSDictionary *serviceTXTRecords;

@end


@implementation ServiceDetailViewController

@synthesize selectedService = _selectedService;
@synthesize serviceTXTRecords = _serviceTXTRecords;


#pragma mark - 
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.selectedService.name;
    
    self.serviceTXTRecords = [NSNetService dictionaryFromTXTRecordData:self.selectedService.TXTRecordData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.selectedService stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Allow all orientations
    return YES;
}

- (void)dealloc
{
    self.selectedService = nil;
    self.serviceTXTRecords = nil;
    [super dealloc];
}

#pragma mark - 
#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = 3;
            break;
        case 1:
            numberOfRows = self.selectedService.addresses.count;
            break;
        case 2:
        {
            numberOfRows = 0;
            if (self.serviceTXTRecords != nil) {
                numberOfRows = [self.serviceTXTRecords allKeys].count;
            }
        }
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *headerName = @"";
    
    switch (section) {
        case 0:
            headerName = @"Service Information";
            break;
        case 1:
            headerName = @"Addresses";
            break;
        case 2:
            if ([self tableView:tableView numberOfRowsInSection:section] != 0) {
                headerName = @"TXT Records";
            }
            break;
    }
    
    return headerName;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Value1CellIdentifier = @"Value1Cell";
    static NSString *DefaultCellIdentifier = @"DefaultCell";
    
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:Value1CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Value1CellIdentifier] autorelease];
            }

            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Service Name";
                    cell.detailTextLabel.text = self.selectedService.name;
                    break;
                case 1:
                    cell.textLabel.text = @"Service Type";
                    cell.detailTextLabel.text = self.selectedService.type;
                    break;
                case 2: 
                    cell.textLabel.text = @"Domain";
                    cell.detailTextLabel.text = self.selectedService.domain;
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DefaultCellIdentifier] autorelease];
            }
            
            cell.textLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSData *address = [self.selectedService.addresses objectAtIndex:indexPath.row];
            char addressString[INET6_ADDRSTRLEN];
            int inetType;
            
            struct sockaddr_in6 addr6;
            memcpy(&addr6, address.bytes, address.length);
            uint16_t port = ntohs(addr6.sin6_port);
            
            if (address.length == 16) { // IPv4
                inetType = AF_INET;
                struct sockaddr_in addr4;
                memcpy(&addr4, address.bytes, address.length);
                inet_ntop(AF_INET, &addr4.sin_addr, addressString, 512);
            } else if (address.length == 28) { // IPV6
                inetType = AF_INET6;
                struct sockaddr_in6 addr6;
                memcpy(&addr6, address.bytes, address.length);
                inet_ntop(AF_INET6, &addr6.sin6_addr, addressString, 512);
            }        
            
            if (inetType == AF_INET) {
                cell.textLabel.text = [NSString stringWithFormat:@"%s:%i", addressString, port];            
            } else if (inetType == AF_INET6) {
                cell.textLabel.text = [NSString stringWithFormat:@"[%s]:%i", addressString, port];            
            }
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:Value1CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Value1CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @""; 
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if (self.serviceTXTRecords != nil) {
                NSString *TXTRecordDictionaryKey = [[self.serviceTXTRecords allKeys] objectAtIndex:indexPath.row];
                NSData *TXTRecordDictionaryValueData = [self.serviceTXTRecords objectForKey:TXTRecordDictionaryKey];
                NSString *TXTRecordDictionaryValueString = [[NSString alloc] initWithData:TXTRecordDictionaryValueData encoding:NSUTF8StringEncoding];
                cell.textLabel.text = TXTRecordDictionaryKey;
                cell.detailTextLabel.text = TXTRecordDictionaryValueString;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - 
#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
}

@end
