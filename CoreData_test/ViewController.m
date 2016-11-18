//
//  ViewController.m
//  CoreData_test
//
//  Created by 鹏 刘 on 16/9/27.
//  Copyright © 2016年 鹏 刘. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Students.h"
#import "ClassNumber.h"

@interface ViewController () <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSManagedObjectContext *schoolMoc;
@property (nonatomic,strong) UIButton *add;
@property (nonatomic,strong) UIButton *delete;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultController;
@property (nonatomic,strong) UIButton *refresh;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.add = [[UIButton alloc] initWithFrame:CGRectMake(5, 500, 95, 55)];
    self.add.backgroundColor = [UIColor blackColor];
    [self.add setTitle:@"Add" forState:UIControlStateNormal];
    [self.add addTarget:self action:@selector(addEntity:) forControlEvents:UIControlEventTouchDown];
    
    self.delete = [[UIButton alloc] initWithFrame:CGRectMake(120, 500, 95, 55)];
    self.delete.backgroundColor = [UIColor blueColor];
    [self.delete setTitle:@"Delete" forState:UIControlStateNormal];
    [self.delete addTarget:self action:@selector(deleteEntity:) forControlEvents:UIControlEventTouchDown];
    
    self.refresh = [[UIButton alloc] initWithFrame:CGRectMake(240, 500, 95, 55)];
    self.refresh.backgroundColor = [UIColor redColor];
    [self.refresh setTitle:@"refresh" forState:UIControlStateNormal];
    [self.refresh addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchDown];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,(self.view.bounds.size.height - 55)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.refresh];
    [self.view addSubview:self.add];
    [self.view addSubview:self.delete];

}

- (NSManagedObjectContext *)contextWithModelName:(NSString *)modelName
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    
    NSPersistentStoreCoordinator *ps = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingString:@"%@.sqlite"];
    [ps addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:nil];
   
    context.persistentStoreCoordinator = ps;
    
    return context;
}

- (NSManagedObjectContext *)schoolMoc
{
    if(!_schoolMoc) {
        _schoolMoc = [self contextWithModelName:@"Model"];
    }

    return _schoolMoc;
    
}

- (IBAction)changeView:(id)sender
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Students"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sort];
    
    
    NSError *error = nil;
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.schoolMoc sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultController performFetch:&error];
    self.fetchedResultController.delegate = self;
    
    if (error) {
        NSLog(@"tableView change data is error: %@",error);
    }
    
    [self.tableView reloadData];
}



- (IBAction)addEntity:(id)sender
{
    Students *students = [NSEntityDescription insertNewObjectForEntityForName:@"Students" inManagedObjectContext:self.schoolMoc];
    students.age = @"20";
    students.name = @"Liu Peng";
    
    
    NSError *error = nil;
    if (self.schoolMoc.hasChanges) {
        [self.schoolMoc save:&error];
        NSLog(@"%@",students);
    }

    if (error) {
        NSLog(@"CoreData insert data error:%@",error);
    }

}

- (IBAction)deleteEntity:(id)sender
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Students"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",@"Liu Peng"];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *students = [self.schoolMoc executeFetchRequest:request error:&error];
    
    [students enumerateObjectsUsingBlock:^(Students *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.schoolMoc deleteObject:obj];
    }];
    
  
    if (self.schoolMoc.hasChanges) {
        [self.schoolMoc save:&error];
        NSLog(@"%@",students);
    }

    if (error) {
        NSLog(@"CoreData delete data error:%@",error);
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Students *students = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell;
    static NSString *reuseIdentifier = @"identifier";
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    
    cell.textLabel.text = students.name;
    cell.detailTextLabel.text = students.age;
    
    return cell;
}


@end
