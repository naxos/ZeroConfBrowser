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

#import "ServiceTypesTableViewController.h"
#import "ServicesTableViewController.h"

@interface ServiceTypesTableViewController () <NSNetServiceBrowserDelegate>

@end

@implementation ServiceTypesTableViewController {
    NSNetServiceBrowser *_serviceBrowser;
    NSMutableArray<NSNetService *> *_services;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.domainName;
    
    _services = [NSMutableArray new];
    
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    _serviceBrowser.delegate = self;
    
    [_serviceBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:self.domainName];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ServicesTableViewController *dest = segue.destinationViewController;
    
    dest.domainName = self.domainName;
    dest.serviceType = [self _serviceIdentifier:[_services objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceTypeCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self _serviceIdentifier:[_services objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Net service browser delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    
    [_services addObject:service];

    if (!moreComing) {
        [self.tableView reloadData];
    }
}

#pragma mark - Private methods

- (NSString *)_serviceIdentifier:(NSNetService *)service {
    NSString *name = service.name;
    NSString *type = service.type;
    
    if ([type hasSuffix:self.domainName]) {
        type = [type substringToIndex:type.length - self.domainName.length];
    }
    
    return [NSString stringWithFormat:@"%@.%@", name, type];
}

@end
