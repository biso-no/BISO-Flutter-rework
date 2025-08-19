// Script to add the is_public boolean attribute to the user collection
// This should be run in the Appwrite console or using the Appwrite CLI

// Appwrite Console Steps:
// 1. Go to Database > app > user collection
// 2. Click "Add Attribute"
// 3. Select "Boolean"
// 4. Set Key: "is_public"
// 5. Set Default: false (or leave unset for nullable)
// 6. Required: No (to allow existing users to have null)
// 7. Array: No
// 8. Click "Create"

// Alternatively, use Appwrite CLI:
// appwrite databases createBooleanAttribute \
//   --databaseId app \
//   --collectionId user \
//   --key is_public \
//   --required false \
//   --default false

// Or use the MCP function (if available):
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    print('Run this script in Appwrite Console to add is_public attribute:');
    print('1. Navigate to Database > app > user collection');
    print('2. Click "Add Attribute"');
    print('3. Select "Boolean"');
    print('4. Key: "is_public"');
    print('5. Required: false');
    print('6. Default: false (optional)');
    print('7. Array: false');
    print('8. Click "Create"');
    print('');
    print('This will add privacy control to user profiles.');
  }
}
