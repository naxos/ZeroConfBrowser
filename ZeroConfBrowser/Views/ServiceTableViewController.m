// -----------------------------------------------------------------------------
// This file is part of the ZeroConfBrowser example.
//
// Copyright © 2016 Naxos Software Solutions GmbH. All rights reserved.
//
// Author: Martin Schaefer <martin.schaefer@naxos-software.de>
//
// ZeroConfBrowser is licensed under the Simplified BSD License
// -----------------------------------------------------------------------------
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

#import "ServiceTableViewController.h"
#import <arpa/inet.h>

@interface ServiceTableViewController () <NSNetServiceDelegate>

@end

@implementation ServiceTableViewController {
    NSMutableArray<NSString *> *_ipAddresses;
    NSDictionary *_txtRecords;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.service.name;

    if (_service.addresses.count) {
        // Already got data
        [self netServiceDidResolveAddress:_service];
    }
    
    _service.delegate = self;
    
    [_service resolveWithTimeout:0];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Host:Port";
        case 1:
            return @"IP Addresses";
        case 2:
            return @"TXT Records";
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _ipAddresses.count ? (_txtRecords.count ? 3 : 2) : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _service.hostName ? 1 : 0;
        case 1:
            return _ipAddresses.count;
        case 2:
            return _txtRecords.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"simpleCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"%@:%ld", _service.hostName, (long)_service.port];
            break;
        }
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"simpleCell" forIndexPath:indexPath];
            cell.textLabel.text = [_ipAddresses objectAtIndex:indexPath.row];
            break;
        case 2: {
            NSString *key = [_txtRecords.allKeys objectAtIndex:indexPath.row];
            NSData *val = [_txtRecords objectForKey:key];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Net service delegate

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    
    _ipAddresses = [NSMutableArray new];
    
    for (NSData *addrData in service.addresses) {
        [_ipAddresses addObject:[self _ipAddress:addrData]];
    }
    
    _txtRecords = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
    
    [self.tableView reloadData];
}

#pragma mark - Private methods

- (NSString *)_ipAddress:(NSData *)addrData {
    struct sockaddr *addr = (struct sockaddr *)addrData.bytes;
    char *s = NULL;
    NSString *ipAddress = nil;
    
    switch(addr->sa_family) {
        case AF_INET: {
            struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
            s = malloc(INET_ADDRSTRLEN);
            inet_ntop(AF_INET, &(addr_in->sin_addr), s, INET_ADDRSTRLEN);
            break;
        }
        case AF_INET6: {
            struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addr;
            s = malloc(INET6_ADDRSTRLEN);
            inet_ntop(AF_INET6, &(addr_in6->sin6_addr), s, INET6_ADDRSTRLEN);
            break;
        }
        default:
            break;
    }
    
    if (s) {
        ipAddress = [NSString stringWithUTF8String:s];
        free(s);
    }
    
    return ipAddress;
}

@end
