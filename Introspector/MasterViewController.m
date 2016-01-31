//
//  MasterViewController.m
//  Introspector
//
//  Created by Moshe Berman on 1/30/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "INTIntrospector.h"

@interface MasterViewController () <UISearchBarDelegate> {
    BOOL invalid;
}

@property NSArray *objects;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    INTIntrospector *i = [[INTIntrospector alloc] init];
    
    Class targetClass = NSClassFromString(@"NSObject");
    self.objects = [i subclassesOfClass:targetClass];
    
    self.title = [NSString stringWithFormat:@"%lu Classes", (unsigned long)self.searchedClasses.count];
    
    invalid = false;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Class object = self.searchedClasses[indexPath.row];
        
        DetailViewController *dtv = (DetailViewController *)[[segue destinationViewController]topViewController];
        dtv.targetClass = object;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchedClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.searchedClasses[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - Helpers

- (NSArray *)searchedClasses
{
    if (self.searchBar.text.length == 0)
    {
        invalid = false;
        return self.objects;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        Class c = evaluatedObject;
        NSString *name = NSStringFromClass(c);
        
        NSString *lowercaseSearch = self.searchBar.text.lowercaseString;
        if ([[name lowercaseString] rangeOfString:lowercaseSearch].location != NSNotFound)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }];
    
    static NSArray *results = nil;
    
    if (results == nil || invalid == true)
    {
        results = [self.objects filteredArrayUsingPredicate:predicate];
        invalid = false;
    }
    
    return results;
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    invalid = true;
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"%lu Classes", (unsigned long)self.searchedClasses.count];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    invalid = true;
    searchBar.text = nil;
    [self.tableView reloadData];
    self.title = [NSString stringWithFormat:@"%lu Classes", (unsigned long)self.searchedClasses.count];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


@end
