//
//  Contacts.m
//  Zing
//
//  Created by Kostas on 8/21/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "Contacts.h"
#import "Contact.h"

@interface Contacts ()


@end

@implementation Contacts

{
    
    NSMutableArray *contacts;
    NSArray *searchResults;
    
    NSInteger numberOfPeople;
    NSArray *allPeople;
    
    Contact *contact;
    UserInfo *userinfo;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize user info object
    self.user = [UserInfo user];
    
    
    
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                //                [self listPeopleInAddressBook:addressBookRef];
                //                if (addressBookRef) CFRelease(addressBookRef);
                NSLog(@"_addContactToAddressBook1");
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        //[self _addContactToAddressBook];
        //NSLog(@"_addContactToAddressBook2");
        [self listPeopleInAddressBook:addressBookRef];
        if (addressBookRef) CFRelease(addressBookRef);
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//*********************************************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [contacts count];
    }
}

//*******************************

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}

//*******************************

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    ContactsCell *cell = (ContactsCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display recipe in the table cell
    contact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = [searchResults objectAtIndex:indexPath.row];
    } else {
        contact = [contacts objectAtIndex:indexPath.row];
    }
    
    cell.name.text = contact.name;
    cell.photo.image = contact.photo;
    cell.phone.text = contact.phone;
    
    return cell;
}

//*******************************

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = [searchResults objectAtIndex:indexPath.row];
    } else {
        contact = [contacts objectAtIndex:indexPath.row];
    }
    [self sendSMS:contact];
    
    //    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:contact.name message:@"Send an invitation to get Zing" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    //    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //    [alert addButtonWithTitle:@"Send"];
    //    UITextField* textField = [alert textFieldAtIndex:0];
    //    textField.text =contact.phone;
    //    [alert show];
    
}

//***********

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1) {  //Send
//        UITextField *phone = [alertView textFieldAtIndex:0];
//        NSLog(@"phone: %@", [phone.text isEqualToString:(@"")]?contact.phone:phone.text);
//        [self sendSMS:contact];
//
//    }
//}


//*********************************************************************************************************

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [contacts filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

//*********************************************************************************************************

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook
{
    contacts = [NSMutableArray new];
    numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSData  *imgData = CFBridgingRelease(ABPersonCopyImageData(person));
        
        // NSLog(@"Name:%@ %@", firstName, lastName);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            //    NSLog(@"  phone:%@", phoneNumber);
            contact = [Contact new];
            contact.name = [NSString stringWithFormat:@"%@ %@", (firstName==NULL)?@"":firstName, (lastName==NULL)?@"":lastName];
            contact.phone = [NSString stringWithFormat:@"%@", (phoneNumber==NULL)?@"":phoneNumber];
            contact.photo = [UIImage imageWithData:imgData];
            [contacts addObject:contact];
        }
        
        CFRelease(phoneNumbers);
        
        //  NSLog(@"=============================================");
    }
}





//**************************************************************************************

- (void)sendSMS:(Contact*)myContact {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipients = @[myContact.phone];
    NSString *message = [NSString stringWithFormat:@"%@ would like to invite you to use zing\nThank you", myContact.name];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            NSLog(@"CANCELED");
            // [self presentViewController:self animated:YES completion:nil];
            //            UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsVC"];
            //            [self.navigationController presentViewController:viewController animated:YES completion:nil];
            
            break;
        }
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            NSLog(@"SENT");
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@""]]];
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
