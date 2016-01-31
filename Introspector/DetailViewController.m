//
//  DetailViewController.m
//  Introspector
//
//  Created by Moshe Berman on 1/30/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import "DetailViewController.h"
#import "INTIntrospector.h"

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewToggle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController {
    BOOL invalid;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _targetClass = [NSObject class];
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setTargetClass:(Class)targetClass
{
    _targetClass = targetClass;
    
    [self configureView];
}

- (void)configureView {

    invalid = true;
    
    if (self.targetClass)
    {
        NSString *classString = NSStringFromClass(self.targetClass);
        Class superclass = [[self.targetClass superclass] class];
        
        NSString *superClassString = NSStringFromClass(superclass);
        
        if (superClassString) {
            self.navigationItem.prompt = [NSString stringWithFormat:@"%@ (%@)", classString, superClassString];
        }
        else
        {
            self.navigationItem.prompt = classString;
        }
        
        [self.tableView reloadData];
    }
}

- (IBAction)selectedSegmentChanged:(id)sender
{
    [self configureView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)dataSource
{
    static NSArray *data = nil;

    if (!data || invalid) {
        if (self.viewToggle.selectedSegmentIndex == 0)
        {
            data = [[[INTIntrospector alloc] init] propertiesOfClass:self.targetClass].allKeys;
        }
        else if (self.viewToggle.selectedSegmentIndex == 1)
        {
            data = [[[INTIntrospector alloc] init] methodsFromClass:self.targetClass];
        }
        else if (self.viewToggle.selectedSegmentIndex == 2)
        {
            data = [[[INTIntrospector alloc] init] subclassesOfClass:self.targetClass];
        }
        invalid = false;
    }
    
    return data;
}

#pragma mark - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sections
{
    return [self dataSource].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.dataSource;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (data.count > 0 && indexPath.row < data.count)
    {
        NSString *title = data[indexPath.row];
        if (self.viewToggle.selectedSegmentIndex == 2)
        {
            title = NSStringFromClass(data[indexPath.row]);
        }
        
        cell.textLabel.text = title;
        
        if (self.viewToggle.selectedSegmentIndex == 0)
        {
            cell.detailTextLabel.text = [[[INTIntrospector alloc] init] propertiesOfClass:self.targetClass][title];
        }
        else
        {
            cell.detailTextLabel.text = nil;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (self.viewToggle.selectedSegmentIndex == 2)
    {
        // TODO: Show subclass
    }
}
@end
