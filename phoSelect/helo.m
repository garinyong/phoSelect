//
//  AddressTools.m
//  PhoneTools
//  通讯录工具
//  Created by garin on 14-5-15.
//  Copyright (c) 2014年 garin. All rights reserved.
//

#import "AddressTools.h"
#import <AddressBook/AddressBook.h>
#import "PhoneInfosDataAccess.h"

static BOOL isStoped;

@implementation AddressTools

+(void) setStoped:(BOOL) _value_
{
    isStoped = _value_;
}

+(void) updateMobileLocationInfos
{
    isStoped = NO;
    
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
    {
        return;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    NSArray * peopleArr = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    int peopleIndex = 0;
    
    for(id obj in peopleArr)
    {
        if (isStoped)
        {
            break;
        }
        
        ABRecordRef people = (ABRecordRef)obj;
        
        peopleIndex ++;
        
        if (!people)
        {
            continue;
        }
        
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, ABRecordGetRecordID(people));
        
        NSString *personName = (NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        
        NSString *lastname = (NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
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
            
            NSString *newKey = [AddressTools getLocationString:(NSString *)value];
            
            if (!STRINGHASVALUE(newKey))
            {
                if (key)
                {
                    CFRelease(key);
                }
                if (value)
                {
                    CFRelease(value);
                }
                continue;
            }
            
            ABMultiValueReplaceLabelAtIndex(phones,(CFStringRef)newKey,j);
            
            ABRecordSetValue(record, kABPersonPhoneProperty ,phones, nil);
            
            if (key)
            {
                CFRelease(key);
            }
            if (value)
            {
                CFRelease(value);
            }
        }
        
        NSString * tem = [NSString stringWithFormat:@"%d/%d %@%@",peopleIndex,(int)peopleArr.count,
                          STRINGHASVALUE(lastname)?lastname:@"" ,STRINGHASVALUE(personName)?personName:@""];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UpdateLoadingViewTips object:tem];
        
        [personName release];
        [lastname release];
        
        if (phones)
        {
            CFRelease(phones);
        }
        
        //        sleep(1);
        ABAddressBookSave(addressBook, NULL);
    }
    
    [peopleArr release];
    
    //    ABAddressBookSave(addressBook, NULL); //wait to 优化
    
    if (addressBook)
    {
        CFRelease(addressBook);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UpdateLoadingViewTips object:@"通讯录更新完成：）"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    NSLog(@"update ok!");
}

+(NSString *) getLocationString:(NSString *) phoneNo
{
    if (!STRINGHASVALUE(phoneNo)||phoneNo.length<7)
    {
        return @"";
    }
    
    PhoneInfosDataAccess *dataAccess = [PhoneInfosDataAccess shareInstance];
    
    phoneNo = [phoneNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    phoneNo = [phoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNo = [phoneNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    phoneNo = [phoneNo stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    NSString *temString = [phoneNo substringToIndex:7];
    NSString *locationString = [dataAccess queryMobileLocationString:temString];
    
    if (STRINGHASVALUE(locationString))
    {
        locationString = [locationString stringByReplacingOccurrencesOfString:@"卡" withString:@""];
    }
    
    return locationString;
}

+(void) askAuthoriation
{
    if (IOS_VERSION>=6.0)
    {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (granted)
                                                     {
                                                         [AddressTools updateMobileLocationInfos];
                                                     }
                                                     else if (error)
                                                     {
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UpdateLocationFail object:@""];
                                                     }
                                                     else
                                                     {
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UpdateLocationFail object:@""];
                                                     }
                                                 });
        
        if (addressBookRef)
        {
            CFRelease(addressBookRef);
        }
    }
    else
    {
        [AddressTools updateMobileLocationInfos];
    }
}

+(void) updateAddressSheet
{
    return;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    //    注意，在用完的时候，一定要进行release，不然会导致内存泄露，当然这里是CFRelease
    
    //    2、增加一个新联系人到通讯录中
    //初始化一个record
    ABRecordRef person = ABPersonCreate();
    
    //这是一个空的记录，或者说是没有任何信息的联系人
    //下面给这个人 添加一个名字
    NSString *firstName = @"Tr";
    ABRecordSetValue(person, kABPersonFirstNameProperty, (CFStringRef)firstName, NULL);
    CFStringRef lastName = (CFStringRef)@"Lee";
    ABRecordSetValue(person, kABPersonLastNameProperty, lastName, NULL);
    //给他再加一个生日
    NSDate *bdate = [NSDate date];
    ABRecordSetValue(person, kABPersonBirthdayProperty, (CFDateRef)bdate, NULL);
    //这些都是单一值属性的设置，接下来看看多值属性的设置
    NSArray *phones = [NSArray arrayWithObjects:@"123", @"456", nil];
    NSArray *labels = [NSArray arrayWithObjects:@"iphone", @"home", nil];
    //初始化一个多值对象，类似字典
    ABMutableMultiValueRef mulRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //循环设置值
    for(int i = 0; i < phones.count; i++){
        ABMultiValueIdentifier multivalueIdentifier;
        ABMultiValueAddValueAndLabel(mulRef, (CFStringRef)[phones objectAtIndex:i], (CFStringRef)[labels objectAtIndex:i], &multivalueIdentifier);
    }
    ABRecordSetValue(person, kABPersonPhoneProperty, mulRef, NULL);
    if(mulRef)
        CFRelease(mulRef);
    
    //将新的记录，添加到通讯录中
    ABAddressBookAddRecord(addressBook, person, NULL);
    //通讯录执行保存
    ABAddressBookSave(addressBook, NULL);
    //不说了，你懂的～
    if(addressBook)
        CFRelease(addressBook);
    //    举例如何清空所有联系人
    //    1、首先初始化ABAddressBookRef对象 addressBook
    //    2、循环删除
    //    for(id obj in (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook)){
    //        ABRecordRef people = (ABRecordRef)obj;
    
    //        NSArray * arr = ABRecordCopyValue(people, kABPersonPhoneProperty);
    
    //        ABAddressBookRemoveRecord(addressBook, people, NULL);
    //    }
    //    3、执行保存操作
    ABAddressBookSave(addressBook, NULL);
    //    4、别忘了释放
    if(addressBook)
        CFRelease(addressBook);
}

@end