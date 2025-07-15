import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

const schema = a.schema({
  // User Profile
  UserProfile: a
    .model({
      userId: a.id().required(),
      email: a.email().required(),
      firstName: a.string().required(),
      lastName: a.string().required(),
      phoneNumber: a.phone(),
      dateOfBirth: a.date(),
      address: a.string(),
      kycStatus: a.enum(['PENDING', 'APPROVED', 'REJECTED', 'UNDER_REVIEW']),
      accountType: a.enum(['INDIVIDUAL', 'CORPORATE']),
      riskProfile: a.enum(['CONSERVATIVE', 'MODERATE', 'AGGRESSIVE']),
      createdAt: a.datetime(),
      updatedAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.groups(['admin', 'kyc_officer']).to(['read', 'update']),
    ]),

  // KYC Documents
  KYCDocument: a
    .model({
      userId: a.id().required(),
      documentType: a.enum(['ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE', 'UTILITY_BILL', 'BANK_STATEMENT']),
      documentUrl: a.url(),
      status: a.enum(['PENDING', 'APPROVED', 'REJECTED']),
      rejectionReason: a.string(),
      uploadedAt: a.datetime(),
      reviewedAt: a.datetime(),
      reviewedBy: a.id(),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.groups(['admin', 'kyc_officer']).to(['read', 'update']),
    ]),

  // Investment Funds
  InvestmentFund: a
    .model({
      name: a.string().required(),
      description: a.string(),
      fundType: a.enum(['EQUITY', 'BOND', 'MIXED', 'MONEY_MARKET']),
      minimumInvestment: a.float().required(),
      managementFee: a.float(),
      performanceFee: a.float(),
      riskLevel: a.enum(['LOW', 'MEDIUM', 'HIGH']),
      currency: a.string().default('NGN'),
      isActive: a.boolean().default(true),
      fundManagerId: a.id(),
      totalValue: a.float().default(0),
      totalUnits: a.float().default(0),
      navPerUnit: a.float().default(1),
      createdAt: a.datetime(),
      updatedAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.authenticated().to(['read']),
      allow.groups(['admin', 'fund_manager']).to(['create', 'update', 'delete']),
    ]),

  // User Investments
  Investment: a
    .model({
      userId: a.id().required(),
      fundId: a.id().required(),
      units: a.float().required(),
      totalAmount: a.float().required(),
      purchasePrice: a.float().required(),
      currentValue: a.float(),
      status: a.enum(['ACTIVE', 'REDEEMED', 'PENDING']),
      investmentDate: a.datetime(),
      redemptionDate: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.groups(['admin', 'fund_manager']).to(['read']),
    ]),

  // Investment Groups
  InvestmentGroup: a
    .model({
      name: a.string().required(),
      description: a.string(),
      targetAmount: a.float().required(),
      currentAmount: a.float().default(0),
      minimumContribution: a.float().required(),
      maximumMembers: a.integer(),
      currentMembers: a.integer().default(0),
      fundId: a.id().required(),
      creatorId: a.id().required(),
      status: a.enum(['OPEN', 'CLOSED', 'ACTIVE', 'COMPLETED']),
      startDate: a.date(),
      endDate: a.date(),
      createdAt: a.datetime(),
      updatedAt: a.datetime(),
      // Relationships
      fund: a.belongsTo('InvestmentFund', 'fundId'),
      memberships: a.hasMany('GroupMembership', 'groupId'),
    })
    .authorization((allow) => [
      allow.authenticated().to(['read']),
      allow.owner(),
      allow.groups(['admin']).to(['create', 'update', 'delete']),
    ]),

  // Group Memberships
  GroupMembership: a
    .model({
      userId: a.id().required(),
      groupId: a.id().required(),
      contributionAmount: a.float().required(),
      status: a.enum(['PENDING', 'ACTIVE', 'INACTIVE']),
      joinedAt: a.datetime(),
      // Relationships
      group: a.belongsTo('InvestmentGroup', 'groupId'),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.groups(['admin']).to(['read', 'update']),
    ]),

  // Transactions
  Transaction: a
    .model({
      userId: a.id().required(),
      type: a.enum(['INVESTMENT', 'REDEMPTION', 'DIVIDEND', 'FEE']),
      amount: a.float().required(),
      currency: a.string().default('NGN'),
      status: a.enum(['PENDING', 'COMPLETED', 'FAILED', 'CANCELLED']),
      reference: a.string(),
      description: a.string(),
      investmentId: a.id(),
      groupId: a.id(),
      paymentMethod: a.enum(['BANK_TRANSFER', 'CARD', 'WALLET']),
      transactionDate: a.datetime(),
      completedAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner(),
      allow.groups(['admin', 'fund_manager']).to(['read']),
    ]),

  // Notifications
  Notification: a
    .model({
      userId: a.id().required(),
      title: a.string().required(),
      message: a.string().required(),
      type: a.enum(['INFO', 'WARNING', 'SUCCESS', 'ERROR']),
      category: a.enum(['INVESTMENT', 'KYC', 'TRANSACTION', 'GROUP', 'SYSTEM']),
      isRead: a.boolean().default(false),
      actionUrl: a.url(),
      createdAt: a.datetime(),
    })
    .authorization((allow) => [allow.owner()]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
  },
});
