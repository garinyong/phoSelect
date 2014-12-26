//
//  ViewController.m
//  phoSelect
//
//  Created by GaoYong on 14/12/25.
//
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import "sqlTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"test");
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (granted)
                                                     {
                                                         [self getMobileLocationInfos];
                                                     }
                                                 });
        
        if (addressBookRef)
        {
            CFRelease(addressBookRef);
        }
    }
}

-(void) getMobileLocationInfos
{
    sqlTool *tool = [sqlTool new];
    
    return;
    
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
    {
        return;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    NSArray * peopleArr = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    int peopleIndex = 0;
    
    NSMutableArray *saveData = [NSMutableArray array];
    
    for(id obj in peopleArr)
    {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        
        peopleIndex ++;
        
        if (!people)
        {
            continue;
        }
        
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, ABRecordGetRecordID(people));
        
        NSString *personName = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
        
//        if (peopleIndex > 160)
//        {
//            NSLog(@"alert");
//        }
        
        NSLog(@"peopleIndex:%d",peopleIndex);
        
        if (peopleIndex < 162)
        {
            continue;
        }
        
        //所有的电话
        ABMutableMultiValueRef multiPhones  = ABRecordCopyValue(record, kABPersonPhoneProperty);
        ABMutableMultiValueRef phones = ABMultiValueCreateMutableCopy(multiPhones);
        if(multiPhones)
        {
            CFRelease(multiPhones);
        }
        CFIndex innnerCount = ABMultiValueGetCount(phones);
        
        for (int j = 0; j < innnerCount; j++)
        {
            CFStringRef key = ABMultiValueCopyLabelAtIndex(phones,j);
            
            CFStringRef value = ABMultiValueCopyValueAtIndex(phones,j);
            
            NSLog(@"key:%@ value:%@",key,value);
            
            NSMutableDictionary *temDDD = [NSMutableDictionary dictionary];
            
            if (key)
            {
                [temDDD setObject:(__bridge id)(key) forKey:@"desp"];
            }

            if (value)
            {
                [temDDD setObject:(__bridge id)(value) forKey:@"pno"];
            }
            
            [saveData addObject:temDDD];
        }
        
        if (phones)
        {
            CFRelease(phones);
        }
        
        //        sleep(1);
        ABAddressBookSave(addressBook, NULL);
    }
    
    //    ABAddressBookSave(addressBook, NULL); //wait to 优化
    
    if (addressBook)
    {
        CFRelease(addressBook);
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    
    if (saveData.count > 0)
    {
        sqlTool *tool = [sqlTool new];
        [tool saveData:saveData];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
