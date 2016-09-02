/*
   Copyright 2011 Mavens Consulting, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

@isTest
private class SmartFactory_Test {
	static {
		SmartFactory.FillAllFields = false; // increase test coverage without creating custom objects
	}

	static testMethod void createSObjectList() {
		Test.startTest();
		List<Account> testAccountList = (List<Account>)SmartFactory.createSObjectList('Account', false, 5);
		insert testAccountList;
		for(Account testAccount : testAccountList) {
			System.assertNotEquals(null, testAccount.Id);
		}
		Test.stopTest();
	}

	static testMethod void createsSingleObjectWithSingleRequiredStringField() {
		Test.startTest();
		Account account = (Account)SmartFactory.createSObject('Account');
		insert account;
		System.assert(account.Id != null);
		System.assert(account.Name != null);
		Test.stopTest();
	}

	static testMethod void createsObjectWithCascadeSetsLookupField() {
		Test.startTest();
		Contact contact = (Contact)SmartFactory.createSObject('Contact', true);
		insert contact;
		System.assert(contact.Id != null);
		System.assert(contact.AccountId != null);
		Test.stopTest();
	}

	static testMethod void createsObjectWithoutCascadeDoesNotSetLookupField() {
		Test.startTest();
		Contact contact = (Contact)SmartFactory.createSObject('Contact', false);
		insert contact;
		System.assert(contact.AccountId == null);
		Test.stopTest();
	}

	static testMethod void createObjectWithUnsupportedTypeThrowsException() {
		Test.startTest();
		try {
			SmartFactory.createSObject('Unsupported');
			System.assert(false);
		} catch (UnsupportedObjectTypeException ex) {
			System.assert(true);
		}
		Test.stopTest();
	}
}