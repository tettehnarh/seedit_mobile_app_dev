import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
  name: 'seeditStorage',
  access: (allow) => ({
    'kyc-documents/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.groups(['admin', 'kyc_officer']).to(['read']),
    ],
    'profile-pictures/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete']),
      allow.authenticated.to(['read']),
    ],
    'fund-documents/*': [
      allow.authenticated.to(['read']),
      allow.groups(['admin', 'fund_manager']).to(['read', 'write', 'delete']),
    ],
    'reports/*': [
      allow.groups(['admin', 'fund_manager']).to(['read', 'write', 'delete']),
      allow.authenticated.to(['read']),
    ],
    'public/*': [
      allow.guest.to(['read']),
      allow.authenticated.to(['read']),
      allow.groups(['admin']).to(['read', 'write', 'delete']),
    ],
  }),
});
