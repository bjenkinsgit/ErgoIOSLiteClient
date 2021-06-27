#  ERGO iOS Lite Client version 1.0, build 14 for iOS 13.2+

The Ergo iOS lite client is an iOS app that tethers to any existing, running ERGO reference node you have running somewhere on your network.  As long as you can reach your ERGO reference node from your phone via a web-browser, you can interact with it in a more mobile friendly way with this app.

To learn how to setup your own reference node under your control please refer to:
[ERGO node setup] (https://github.com/ergoplatform/ergo/wiki/Set-up-a-full-node)

This app was made to mitigate some of the usability headaches I encountered when using the /swagger or /panel web screens provided by the ERGO web reference implementation.  The ERGO web pages are very good, but are not designed for the small form factor of a phone.

Features:
-  Uses biometrics for security (both FaceID and TouchID with password as a fallback).
-  Supports having multiple accounts and the ability to easily move between them.
-  Stores auth keys and sensitive data in your iphone keychain for security.
-  Backs up key data (payments history and some minimal account data) to a private, iCloud container using NSPersistentCloudKitContainer
   (this allows you see your data from any apple device that is logged into the same iCloud account)
-  Keeps track of payments made from an account.
-  Shows the balance of the currently selected account at the top of each screen in the app.  (tap to toggle between nano ergs and ergs)
-  Show QR code of the currently selected account for quick display to others.
-  Sending payments provides several choices when entering a payee:  Type in the p2pk address directly, scan a QR code, select from one of your accounts (a funds transfer style operation between your existing accounts), or select a payee from your iPhone contacts address list for anyone that has the custom 'ergo' field added.  When reviewing payment detail, long pressing on the transaction id in the payment detail sreen will allow you to either copy the transaction to the clipboard (for later pasting into an email or message) or to be taken directly to the ergo main/test net transaction and view it online via your default web browser.
 
BONUS:  If you have a local VPN setup for your network and can reach your lan when physically away from your network, you can be truly mobile with the iphone app.

