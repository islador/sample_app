Feature: User updatable profiles

	Scenario: The user wishes to change their profile information
		Given The user is logged in
			And on the profile page
		When the user clicks the update profile button
		Then they are given a page where they can edit all their profile information