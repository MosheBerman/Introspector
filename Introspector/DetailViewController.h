//
//  DetailViewController.h
//  Introspector
//
//  Created by Moshe Berman on 1/30/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

