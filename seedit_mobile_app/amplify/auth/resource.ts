import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: {
      verificationEmailStyle: 'CODE',
      verificationEmailSubject: 'Welcome to SeedIt - Verify your email',
      verificationEmailBody: (createCode) =>
        `Use this code to confirm your account: ${createCode()}`,
    },
    phone: true,
  },
  userAttributes: {
    email: {
      required: true,
      mutable: true,
    },
    phone_number: {
      required: true,
      mutable: true,
    },
    given_name: {
      required: true,
      mutable: true,
    },
    family_name: {
      required: true,
      mutable: true,
    },
    birthdate: {
      required: false,
      mutable: true,
    },
    address: {
      required: false,
      mutable: true,
    },
    'custom:kyc_status': {
      dataType: 'String',
      mutable: true,
    },
    'custom:account_type': {
      dataType: 'String',
      mutable: true,
    },
    'custom:risk_profile': {
      dataType: 'String',
      mutable: true,
    },
  },
  groups: ['admin', 'fund_manager', 'investor', 'kyc_officer'],
  multifactor: {
    mode: 'OPTIONAL',
    sms: true,
    totp: true,
  },
});
