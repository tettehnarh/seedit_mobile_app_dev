# Fund Management Application Architecture

## System Overview

### Technology Stack
- **Mobile App**: Flutter (iOS/Android)
- **Admin Dashboard**: Next.js (React-based)
- **Backend**: AWS Amplify with additional AWS services
- **Database**: Amazon DynamoDB + RDS for complex queries
- **Authentication**: AWS Cognito
- **API**: AWS AppSync (GraphQL) + REST APIs via API Gateway
- **File Storage**: Amazon S3
- **Real-time**: AWS AppSync subscriptions
- **Payment Processing**: Stripe/PayPal integration
- **Notifications**: Amazon SNS/SES

## Architecture Components

### 1. Frontend Applications

#### Flutter Mobile App
```
lib/
├── main.dart
├── config/
│   ├── app_config.dart
│   ├── theme.dart
│   └── routes.dart
├── core/
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   ├── payment_service.dart
│   │   └── notification_service.dart
│   ├── models/
│   ├── utils/
│   └── constants/
├── features/
│   ├── auth/
│   ├── wallet/
│   ├── investments/
│   ├── groups/
│   ├── kyc/
│   └── profile/
└── shared/
    ├── widgets/
    ├── components/
    └── providers/
```

#### Next.js Admin Dashboard
```
pages/
├── _app.js
├── _document.js
├── index.js
├── auth/
├── users/
├── funds/
├── groups/
├── kyc/
├── transactions/
└── analytics/

components/
├── layout/
├── charts/
├── tables/
├── forms/
└── ui/

lib/
├── api/
├── auth/
├── utils/
└── hooks/
```

### 2. Backend Architecture

#### AWS Amplify Configuration
```yaml
# amplify/backend/backend-config.json
{
  "auth": {
    "fundmanagementauth": {
      "service": "Cognito",
      "providerPlugin": "awscloudformation"
    }
  },
  "api": {
    "fundmanagementapi": {
      "service": "AppSync",
      "providerPlugin": "awscloudformation"
    }
  },
  "storage": {
    "fundmanagementstorage": {
      "service": "S3",
      "providerPlugin": "awscloudformation"
    }
  },
  "function": {
    "paymentProcessor": {
      "service": "Lambda",
      "providerPlugin": "awscloudformation"
    }
  }
}
```

#### GraphQL Schema (AppSync)
```graphql
# User Management
type User @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  email: String! @index(name: "byEmail")
  profile: UserProfile
  wallet: Wallet @hasOne
  investments: [Investment] @hasMany
  groups: [GroupMembership] @hasMany
  kycStatus: KYCStatus!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type UserProfile {
  firstName: String!
  lastName: String!
  phone: String
  address: Address
  dateOfBirth: AWSDate
  profileImage: String
}

type Address {
  street: String!
  city: String!
  state: String!
  zipCode: String!
  country: String!
}

# Wallet Management
type Wallet @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  userId: ID! @index(name: "byUserId")
  balance: Float!
  currency: String!
  transactions: [Transaction] @hasMany
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type Transaction @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  walletId: ID! @index(name: "byWalletId")
  type: TransactionType!
  amount: Float!
  description: String
  status: TransactionStatus!
  reference: String
  metadata: AWSJSON
  createdAt: AWSDateTime!
}

enum TransactionType {
  DEPOSIT
  WITHDRAWAL
  INVESTMENT
  DIVIDEND
  FEE
}

enum TransactionStatus {
  PENDING
  COMPLETED
  FAILED
  CANCELLED
}

# Investment Management
type Fund @model @auth(rules: [
  {allow: public, operations: [read]}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  name: String!
  description: String!
  minimumInvestment: Float!
  currentValue: Float!
  totalInvested: Float!
  riskLevel: RiskLevel!
  category: FundCategory!
  isActive: Boolean!
  performance: [PerformanceData] @hasMany
  investments: [Investment] @hasMany
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

enum RiskLevel {
  LOW
  MEDIUM
  HIGH
}

enum FundCategory {
  EQUITY
  BOND
  MIXED
  MONEY_MARKET
}

type Investment @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  userId: ID! @index(name: "byUserId")
  fundId: ID! @index(name: "byFundId")
  amount: Float!
  units: Float!
  currentValue: Float!
  groupId: ID @index(name: "byGroupId")
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

# Groups Management
type Group @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  name: String!
  description: String
  targetAmount: Float!
  currentAmount: Float!
  fundId: ID! @index(name: "byFundId")
  creatorId: ID! @index(name: "byCreatorId")
  isActive: Boolean!
  members: [GroupMembership] @hasMany
  investments: [Investment] @hasMany
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type GroupMembership @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  userId: ID! @index(name: "byUserId")
  groupId: ID! @index(name: "byGroupId")
  contributionAmount: Float!
  joinedAt: AWSDateTime!
}

# KYC Management
type KYC @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  userId: ID! @index(name: "byUserId")
  documentType: DocumentType!
  documentNumber: String!
  documentImage: String!
  status: KYCStatus!
  adminNotes: String
  submittedAt: AWSDateTime!
  reviewedAt: AWSDateTime
  reviewedBy: ID
}

enum DocumentType {
  PASSPORT
  DRIVERS_LICENSE
  NATIONAL_ID
  UTILITY_BILL
}

enum KYCStatus {
  PENDING
  APPROVED
  REJECTED
  REQUIRES_REVIEW
}

# Performance Tracking
type PerformanceData @model @auth(rules: [
  {allow: public, operations: [read]}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  fundId: ID! @index(name: "byFundId")
  date: AWSDate!
  value: Float!
  percentageChange: Float!
  createdAt: AWSDateTime!
}

# Withdrawal Requests
type WithdrawalRequest @model @auth(rules: [
  {allow: owner}
  {allow: groups, groups: ["admin"]}
]) {
  id: ID!
  userId: ID! @index(name: "byUserId")
  amount: Float!
  reason: String
  status: WithdrawalStatus!
  requestedAt: AWSDateTime!
  processedAt: AWSDateTime
  processedBy: ID
}

enum WithdrawalStatus {
  PENDING
  APPROVED
  REJECTED
  PROCESSED
}
```

### 3. AWS Lambda Functions

#### Payment Processing Function
```javascript
// amplify/backend/function/paymentProcessor/src/index.js
const AWS = require('aws-sdk');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

exports.handler = async (event) => {
  const { action, payload } = JSON.parse(event.body);
  
  switch (action) {
    case 'create_payment_intent':
      return await createPaymentIntent(payload);
    case 'process_withdrawal':
      return await processWithdrawal(payload);
    case 'handle_webhook':
      return await handleWebhook(payload);
    default:
      return { statusCode: 400, body: JSON.stringify({ error: 'Invalid action' }) };
  }
};

async function createPaymentIntent(payload) {
  try {
    const { amount, currency, customerId } = payload;
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency: currency,
      customer: customerId,
      automatic_payment_methods: { enabled: true }
    });
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        clientSecret: paymentIntent.client_secret
      })
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
}
```

#### KYC Processing Function
```javascript
// amplify/backend/function/kycProcessor/src/index.js
const AWS = require('aws-sdk');
const rekognition = new AWS.Rekognition();
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const { userId, documentImage } = JSON.parse(event.body);
  
  try {
    // Analyze document using Amazon Rekognition
    const result = await rekognition.detectText({
      Image: {
        S3Object: {
          Bucket: process.env.STORAGE_BUCKET,
          Name: documentImage
        }
      }
    }).promise();
    
    // Process extracted text and validate
    const extractedText = result.TextDetections
      .filter(text => text.Type === 'LINE')
      .map(text => text.DetectedText);
    
    // Update KYC status
    await dynamodb.update({
      TableName: process.env.KYC_TABLE,
      Key: { userId: userId },
      UpdateExpression: 'SET #status = :status, extractedData = :data',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':status': 'REQUIRES_REVIEW',
        ':data': extractedText
      }
    }).promise();
    
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'KYC document processed successfully' })
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};
```

### 4. Database Design

#### DynamoDB Tables Structure
```yaml
# User Table
UserTable:
  TableName: User-${env}
  KeySchema:
    - AttributeName: id
      KeyType: HASH
  AttributeDefinitions:
    - AttributeName: id
      AttributeType: S
    - AttributeName: email
      AttributeType: S
  GlobalSecondaryIndexes:
    - IndexName: byEmail
      KeySchema:
        - AttributeName: email
          KeyType: HASH

# Wallet Table
WalletTable:
  TableName: Wallet-${env}
  KeySchema:
    - AttributeName: id
      KeyType: HASH
  AttributeDefinitions:
    - AttributeName: id
      AttributeType: S
    - AttributeName: userId
      AttributeType: S
  GlobalSecondaryIndexes:
    - IndexName: byUserId
      KeySchema:
        - AttributeName: userId
          KeyType: HASH

# Fund Table
FundTable:
  TableName: Fund-${env}
  KeySchema:
    - AttributeName: id
      KeyType: HASH
  AttributeDefinitions:
    - AttributeName: id
      AttributeType: S
    - AttributeName: category
      AttributeType: S
  GlobalSecondaryIndexes:
    - IndexName: byCategory
      KeySchema:
        - AttributeName: category
          KeyType: HASH
```

### 5. Authentication & Authorization

#### AWS Cognito Configuration
```yaml
# amplify/backend/auth/fundmanagementauth/cli-inputs.json
{
  "version": "1",
  "cognitoConfig": {
    "identityPoolName": "fundmanagement_identitypool",
    "allowUnauthenticatedIdentities": false,
    "resourceNameTruncated": "fundma",
    "userPoolName": "fundmanagement_userpool",
    "autoVerifiedAttributes": ["email"],
    "mfaConfiguration": "OPTIONAL",
    "mfaTypes": ["SMS Text Message", "TOTP"],
    "smsAuthenticationMessage": "Your authentication code is {####}",
    "smsVerificationMessage": "Your verification code is {####}",
    "emailVerificationSubject": "Your verification code",
    "emailVerificationMessage": "Your verification code is {####}",
    "defaultPasswordPolicy": {
      "minimumLength": 8,
      "requireUppercase": true,
      "requireLowercase": true,
      "requireNumbers": true,
      "requireSymbols": true
    },
    "usernameAttributes": ["email"],
    "userPoolGroups": [
      {
        "groupName": "admin",
        "precedence": 1
      },
      {
        "groupName": "user",
        "precedence": 2
      }
    ],
    "adminQueries": true
  }
}
```

### 6. Security Implementation

#### API Security
```javascript
// Security middleware for API Gateway
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${process.env.USER_POOL_ID}/.well-known/jwks.json`
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

exports.verifyToken = (event, context, callback) => {
  const token = event.authorizationToken.replace('Bearer ', '');
  
  jwt.verify(token, getKey, {
    audience: process.env.USER_POOL_CLIENT_ID,
    issuer: `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${process.env.USER_POOL_ID}`,
    algorithms: ['RS256']
  }, (err, decoded) => {
    if (err) {
      callback('Unauthorized');
    } else {
      callback(null, generatePolicy(decoded.sub, 'Allow', event.methodArn));
    }
  });
};
```

### 7. Flutter Implementation

#### Service Layer
```dart
// lib/core/services/api_service.dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // GraphQL Operations
  Future<List<Fund>> getFunds() async {
    const String query = '''
      query ListFunds {
        listFunds {
          items {
            id
            name
            description
            minimumInvestment
            currentValue
            riskLevel
            category
            isActive
          }
        }
      }
    ''';

    final request = GraphQLRequest<String>(document: query);
    final response = await Amplify.API.query(request: request).response;
    
    if (response.data != null) {
      final data = json.decode(response.data!);
      return (data['listFunds']['items'] as List)
          .map((item) => Fund.fromJson(item))
          .toList();
    }
    throw Exception('Failed to fetch funds');
  }

  Future<Investment> createInvestment(CreateInvestmentInput input) async {
    const String mutation = '''
      mutation CreateInvestment(\$input: CreateInvestmentInput!) {
        createInvestment(input: \$input) {
          id
          userId
          fundId
          amount
          units
          currentValue
          createdAt
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: mutation,
      variables: {'input': input.toJson()},
    );
    
    final response = await Amplify.API.mutate(request: request).response;
    
    if (response.data != null) {
      final data = json.decode(response.data!);
      return Investment.fromJson(data['createInvestment']);
    }
    throw Exception('Failed to create investment');
  }
}
```

#### State Management (Riverpod)
```dart
// lib/features/investments/providers/investment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final investmentProvider = StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
  return InvestmentNotifier(ref.read(apiServiceProvider));
});

class InvestmentNotifier extends StateNotifier<InvestmentState> {
  final ApiService _apiService;
  
  InvestmentNotifier(this._apiService) : super(InvestmentState.initial());

  Future<void> loadInvestments() async {
    state = state.copyWith(isLoading: true);
    try {
      final investments = await _apiService.getInvestments();
      state = state.copyWith(
        investments: investments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createInvestment(CreateInvestmentInput input) async {
    try {
      final investment = await _apiService.createInvestment(input);
      state = state.copyWith(
        investments: [...state.investments, investment],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
```

### 8. Next.js Admin Dashboard

#### API Routes
```javascript
// pages/api/admin/users.js
import { withApiAuthRequired } from '@auth0/nextjs-auth0';
import { Amplify, API } from 'aws-amplify';

export default withApiAuthRequired(async function handler(req, res) {
  if (req.method === 'GET') {
    try {
      const users = await API.graphql({
        query: `
          query ListUsers {
            listUsers {
              items {
                id
                email
                profile {
                  firstName
                  lastName
                }
                kycStatus
                createdAt
              }
            }
          }
        `
      });
      
      res.status(200).json(users.data.listUsers.items);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
});
```

#### Dashboard Components
```jsx
// components/dashboard/UserManagement.jsx
import { useState, useEffect } from 'react';
import { DataGrid } from '@mui/x-data-grid';

export default function UserManagement() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await fetch('/api/admin/users');
      const userData = await response.json();
      setUsers(userData);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 200 },
    { field: 'email', headerName: 'Email', width: 250 },
    { field: 'firstName', headerName: 'First Name', width: 150 },
    { field: 'lastName', headerName: 'Last Name', width: 150 },
    { field: 'kycStatus', headerName: 'KYC Status', width: 130 },
    {
      field: 'actions',
      headerName: 'Actions',
      width: 200,
      renderCell: (params) => (
        <div>
          <button onClick={() => handleViewUser(params.row.id)}>
            View
          </button>
          <button onClick={() => handleApproveKYC(params.row.id)}>
            Approve KYC
          </button>
        </div>
      )
    }
  ];

  return (
    <div style={{ height: 600, width: '100%' }}>
      <DataGrid
        rows={users}
        columns={columns}
        pageSize={25}
        loading={loading}
        checkboxSelection
      />
    </div>
  );
}
```

### 9. Deployment Configuration

#### AWS Amplify Configuration
```yaml
# amplify.yml
version: 1
applications:
  - appRoot: mobile
    frontend:
      phases:
        preBuild:
          commands:
            - flutter pub get
        build:
          commands:
            - flutter build web
      artifacts:
        baseDirectory: build/web
        files:
          - '**/*'
      cache:
        paths:
          - ~/.pub-cache/**/*
  
  - appRoot: admin-dashboard
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
```

### 10. Security Best Practices

#### Data Protection
- Encrypt sensitive data at rest using AWS KMS
- Use HTTPS for all API communications
- Implement proper input validation and sanitization
- Use AWS WAF for additional protection
- Implement rate limiting on APIs
- Regular security audits and penetration testing

#### Compliance Considerations
- GDPR compliance for European users
- PCI DSS compliance for payment processing
- SOC 2 Type II compliance
- Financial services regulations compliance
- Data residency requirements

### 11. Monitoring and Analytics

#### CloudWatch Configuration
```yaml
# Monitoring setup
CloudWatchDashboard:
  Type: AWS::CloudWatch::Dashboard
  Properties:
    DashboardName: FundManagementMetrics
    DashboardBody: !Sub |
      {
        "widgets": [
          {
            "type": "metric",
            "properties": {
              "metrics": [
                [ "AWS/Lambda", "Duration", "FunctionName", "paymentProcessor" ],
                [ "AWS/Lambda", "Errors", "FunctionName", "paymentProcessor" ]
              ],
              "period": 300,
              "stat": "Average",
              "region": "${AWS::Region}",
              "title": "Payment Processing Metrics"
            }
          }
        ]
      }
```

### 12. Testing Strategy

#### Flutter Testing
```dart
// test/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockAmplifyAPI mockAmplifyAPI;

    setUp(() {
      mockAmplifyAPI = MockAmplifyAPI();
      apiService = ApiService();
    });

    test('should fetch funds successfully', () async {
      // Arrange
      final mockResponse = GraphQLResponse(
        data: '{"listFunds": {"items": []}}',
        errors: null,
      );
      when(mockAmplifyAPI.query(request: anyNamed('request')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiService.getFunds();

      // Assert
      expect(result, isA<List<Fund>>());
    });
  });
}
```

This architecture provides a robust, scalable, and secure foundation for your fund management application with proper separation of concerns, security measures, and compliance considerations.