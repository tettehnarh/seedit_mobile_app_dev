# SeedIt - Investment and Fund Management Platform

SeedIt is a comprehensive investment and fund management platform that enables users to invest in various funds, participate in investment groups, and manage their portfolios through both mobile and web applications.

## 🏗️ Project Structure

```
seedit_mobile_app_dev_v1/
├── seedit_mobile_app/          # Flutter mobile application
├── seedit_web_app/             # Next.js web application
├── .github/workflows/          # CI/CD pipelines
├── start-dev-servers.sh        # Development environment startup script
├── stop-dev-servers.sh         # Development environment shutdown script
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** (v18 or higher)
- **Flutter** (v3.32.4 or higher)
- **AWS CLI** (configured with appropriate credentials)
- **Amplify CLI** (v13.0.1 or higher)
- **Git**

### Development Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd seedit_mobile_app_dev_v1
   ```

2. **Install dependencies**
   ```bash
   # Web application
   cd seedit_web_app
   npm install
   cd ..

   # Mobile application
   cd seedit_mobile_app
   flutter pub get
   cd ..
   ```

3. **Configure environment variables**
   - Copy `.env.local` files and update with your AWS credentials
   - Update Flutter environment configuration in `lib/config/environment.dart`

4. **Start development servers**
   ```bash
   ./start-dev-servers.sh
   ```

5. **Stop development servers**
   ```bash
   ./stop-dev-servers.sh
   ```

## 📱 Mobile Application (Flutter)

### Features
- User authentication and registration
- KYC document upload and verification
- Investment portfolio management
- Investment group participation
- Real-time notifications
- Biometric authentication
- Offline capability

### Key Dependencies
- AWS Amplify for backend services
- Provider/Riverpod for state management
- Go Router for navigation
- HTTP for API communication
- Shared Preferences for local storage

### Development Commands
```bash
cd seedit_mobile_app

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build for release
flutter build apk --release
flutter build ios --release
```

## 🌐 Web Application (Next.js)

### Features
- Responsive dashboard
- Investment analytics and charts
- Fund management interface
- User management and KYC review
- Real-time data visualization
- Admin panel

### Key Dependencies
- Next.js 15 with TypeScript
- AWS Amplify for backend integration
- TanStack Query for data fetching
- Tailwind CSS for styling
- React Hook Form for form management
- Recharts for data visualization

### Development Commands
```bash
cd seedit_web_app

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linting
npm run lint
```

## ☁️ AWS Amplify Backend

### Services Configured
- **Authentication**: Cognito User Pools with MFA
- **API**: GraphQL with DynamoDB
- **Storage**: S3 for file uploads
- **Analytics**: Pinpoint for user analytics

### Data Models
- UserProfile
- KYCDocument
- InvestmentFund
- Investment
- InvestmentGroup
- GroupMembership
- Transaction
- Notification

### Deployment
```bash
# Deploy to staging
amplify env checkout staging
amplify push

# Deploy to production
amplify env checkout production
amplify push
```

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

### Workflows
- **Web Application**: Lint, test, build, and deploy
- **Mobile Application**: Analyze, test, and build APK/IPA
- **Backend**: Deploy Amplify resources
- **Security**: Dependency and security audits

### Branch Strategy
- `main`: Production environment
- `develop`: Staging environment
- `feature/*`: Feature development branches

## 🔧 Configuration

### Environment Variables

#### Web Application (.env.local)
```env
NEXT_PUBLIC_AWS_REGION=us-east-1
NEXT_PUBLIC_USER_POOL_ID=your_user_pool_id
NEXT_PUBLIC_USER_POOL_CLIENT_ID=your_client_id
NEXT_PUBLIC_GRAPHQL_ENDPOINT=your_graphql_endpoint
NEXT_PUBLIC_STORAGE_BUCKET=your_storage_bucket
```

#### Mobile Application (lib/config/environment.dart)
Update the environment configuration file with your AWS resources.

## 🧪 Testing

### Web Application
```bash
cd seedit_web_app
npm run test
npm run test:coverage
```

### Mobile Application
```bash
cd seedit_mobile_app
flutter test
flutter test --coverage
```

## 📦 Deployment

### Staging Deployment
Push to `develop` branch to trigger automatic staging deployment.

### Production Deployment
Push to `main` branch to trigger automatic production deployment.

## 🔒 Security

- Environment variables for sensitive data
- AWS IAM roles and policies
- Cognito authentication with MFA
- File upload restrictions
- API rate limiting
- Security audits in CI/CD

## 📚 Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Next.js Documentation](https://nextjs.org/docs)
- [AWS Amplify Documentation](https://docs.amplify.aws/)
- [Project Architecture](./docs/architecture.md)
- [API Documentation](./docs/api.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Email: support@seedit.com
- Documentation: [docs.seedit.com](https://docs.seedit.com)
- Issues: [GitHub Issues](https://github.com/your-org/seedit/issues)
