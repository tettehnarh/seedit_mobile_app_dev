import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';

class AmplifyConfig {
  static Future<void> configureAmplify() async {
    try {
      // Add the following plugins
      final authPlugin = AmplifyAuthCognito();
      final apiPlugin = AmplifyAPI();
      final storagePlugin = AmplifyStorageS3();

      await Amplify.addPlugins([authPlugin, apiPlugin, storagePlugin]);

      // Configure Amplify
      // Note: Amplify can only be configured once.
      const amplifyConfig = '''
      {
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "1.0",
        "auth": {
          "plugins": {
            "awsCognitoAuthPlugin": {
              "UserAgent": "aws-amplify/cli",
              "Version": "0.1.0",
              "IdentityManager": {
                "Default": {}
              },
              "CredentialsProvider": {
                "CognitoIdentity": {
                  "Default": {
                    "PoolId": "REGION_IDENTITY_POOL_ID",
                    "Region": "REGION"
                  }
                }
              },
              "CognitoUserPool": {
                "Default": {
                  "PoolId": "REGION_USER_POOL_ID",
                  "AppClientId": "APP_CLIENT_ID",
                  "Region": "REGION"
                }
              },
              "Auth": {
                "Default": {
                  "authenticationFlowType": "USER_SRP_AUTH",
                  "socialProviders": [],
                  "usernameAttributes": ["EMAIL", "PHONE_NUMBER"],
                  "signupAttributes": [
                    "EMAIL",
                    "GIVEN_NAME",
                    "FAMILY_NAME",
                    "PHONE_NUMBER"
                  ],
                  "passwordProtectionSettings": {
                    "passwordPolicyMinLength": 8,
                    "passwordPolicyCharacters": [
                      "REQUIRES_LOWERCASE",
                      "REQUIRES_UPPERCASE",
                      "REQUIRES_NUMBERS",
                      "REQUIRES_SYMBOLS"
                    ]
                  },
                  "mfaConfiguration": "OPTIONAL",
                  "mfaTypes": ["SMS", "TOTP"],
                  "verificationMechanisms": ["EMAIL", "PHONE_NUMBER"]
                }
              }
            }
          }
        },
        "api": {
          "plugins": {
            "awsAPIPlugin": {
              "seeditAPI": {
                "endpointType": "GraphQL",
                "endpoint": "GRAPHQL_ENDPOINT",
                "region": "REGION",
                "authorizationType": "AMAZON_COGNITO_USER_POOLS"
              }
            }
          }
        },
        "storage": {
          "plugins": {
            "awsS3StoragePlugin": {
              "bucket": "STORAGE_BUCKET",
              "region": "REGION"
            }
          }
        }
      }
      ''';

      await Amplify.configure(amplifyConfig);
      debugPrint('Amplify configured successfully');
    } catch (e) {
      debugPrint('Error configuring Amplify: $e');
      rethrow;
    }
  }
}
