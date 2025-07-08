# Refab Admin Dashboard

A professional, real-time admin dashboard for the Refab application with full CRUD operations, comprehensive error handling, and robust testing.

## 🚀 Features

- **Real-time Dashboard**: Live updates from Firebase with automatic refresh
- **Comprehensive CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Robust Error Handling**: Graceful error handling with retry logic and user-friendly messages
- **Offline Support**: Detects network status and provides appropriate feedback
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- **Comprehensive Testing**: Unit tests, integration tests, and end-to-end testing
- **Performance Optimized**: Efficient data fetching with caching and batch operations

## 📊 Dashboard Overview

- **Live Statistics**: Real-time counts of users, pickup requests, products, and orders
- **Recent Activity**: Latest pickup requests with status tracking
- **Quick Actions**: Direct navigation to manage different sections
- **System Status**: Real-time monitoring of Firebase connection and services
- **Trend Indicators**: Performance metrics and growth indicators

## 🛠️ Technology Stack

- **Frontend**: Next.js 14, React 18, TypeScript
- **Styling**: Tailwind CSS, Headless UI
- **Backend**: Firebase Firestore, Firebase Auth
- **Testing**: Jest, React Testing Library
- **Icons**: Heroicons
- **Notifications**: React Hot Toast
- **Date Handling**: date-fns

## 📦 Installation

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Firebase project with Firestore enabled

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd admin-dashboard
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure Firebase**
   
   Create a `.env.local` file in the root directory:
   ```env
   NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

5. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

## 🧪 Testing

### Unit Tests
```bash
# Run all unit tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Integration Tests
```bash
# Run integration tests (requires Firebase connection)
npm run test:integration

# Run all tests (unit + integration)
npm run test:all

# Run tests for CI/CD
npm run test:ci
```

### Test Coverage
The test suite covers:
- ✅ Component rendering and interactions
- ✅ Firebase hooks and data operations
- ✅ Error handling and edge cases
- ✅ Real-time updates and offline states
- ✅ Performance and optimization
- ✅ End-to-end integration with Firebase

## 🔧 Development

### Project Structure
```
admin-dashboard/
├── app/                    # Next.js app directory
│   ├── page.js            # Main dashboard page
│   └── layout.js          # Root layout
├── components/            # Reusable UI components
│   ├── ui/               # Base UI components
│   ├── Header.js         # Dashboard header
│   ├── Sidebar.js        # Navigation sidebar
│   └── ...
├── lib/                  # Utility libraries
│   ├── firebase.js       # Firebase configuration
│   └── hooks/            # Custom React hooks
│       └── useFirebase.js # Firebase data hooks
├── __tests__/            # Test files
│   ├── Dashboard.test.js # Dashboard component tests
│   └── hooks/            # Hook tests
├── test-integration.js   # Integration test script
└── package.json          # Dependencies and scripts
```

### Key Components

#### Firebase Hooks (`lib/hooks/useFirebase.js`)
- `useFirebaseCollection()`: Generic CRUD operations for any collection
- `useDashboardStats()`: Dashboard statistics with auto-refresh
- `useRealtimeDashboard()`: Real-time dashboard updates
- `useUsers()`, `usePickupRequests()`, etc.: Specific collection hooks

#### Error Handling
- Automatic retry logic for failed requests
- User-friendly error messages
- Graceful degradation for offline states
- Comprehensive error logging

#### Performance Features
- Batch operations for multiple updates
- Efficient query constraints
- Real-time listeners with cleanup
- Optimized re-renders

## 🚀 Deployment

### Production Build
```bash
# Build for production
npm run build

# Start production server
npm start
```

### Deployment Scripts
```bash
# Full deployment with testing
npm run deploy

# Clean install (if you encounter issues)
npm run clean
```

### Environment Variables
Ensure all Firebase environment variables are set in your production environment:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_production_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_production_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_production_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_production_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_production_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_production_app_id
```

## 🔒 Security

### Firebase Security Rules
Ensure your Firestore security rules allow admin access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin access to all collections
    match /{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Environment Variables
- Never commit `.env.local` to version control
- Use different Firebase projects for development and production
- Regularly rotate API keys

## 📈 Monitoring

### Performance Monitoring
- Real-time connection status
- Automatic error reporting
- Performance metrics tracking
- User activity monitoring

### Error Tracking
- Comprehensive error logging
- User-friendly error messages
- Automatic retry mechanisms
- Offline state detection

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Write tests for new features
- Follow the existing code style
- Update documentation as needed
- Ensure all tests pass before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues

**Firebase Connection Errors**
- Verify environment variables are correct
- Check Firebase project settings
- Ensure Firestore is enabled

**Test Failures**
- Run `npm run clean` to reset dependencies
- Check Firebase emulator is running (if using)
- Verify test environment setup

**Build Errors**
- Clear Next.js cache: `rm -rf .next`
- Update dependencies: `npm update`
- Check TypeScript errors: `npm run type-check`

### Getting Help
- Check the [Issues](../../issues) page for known problems
- Create a new issue with detailed error information
- Include browser console logs and error messages

## 🎯 Roadmap

- [ ] User authentication and role-based access
- [ ] Advanced analytics and reporting
- [ ] Bulk operations and data export
- [ ] Mobile app companion
- [ ] Multi-language support
- [ ] Advanced filtering and search
- [ ] Real-time notifications
- [ ] Data visualization charts

---

**Built with ❤️ for the Refab team** 