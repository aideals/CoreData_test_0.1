//
//  ClassNumber+CoreDataProperties.h
//  CoreData_test
//
//  Created by 鹏 刘 on 16/9/28.
//  Copyright © 2016年 鹏 刘. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClassNumber.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClassNumber (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *number;
@property (nullable, nonatomic, retain) Students *students;

@end

NS_ASSUME_NONNULL_END
