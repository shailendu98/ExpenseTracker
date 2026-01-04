# 💰 Expense Tracking App

A modern, feature-rich iOS expense tracking application built with SwiftUI and Realm database. Track your spending, analyze trends, and manage your finances with ease.

## ✨ Features

### 📊 Core Functionality
- **Transaction Management**: Add, edit, and delete expense transactions
- **Category Organization**: Predefined categories with custom icons and colors
- **Smart Filtering**: Filter transactions by category and search text
- **Multiple Sorting Options**: 
  - Date (Newest/Oldest First)
  - Amount (High to Low / Low to High)
  - Category

### 📈 Reports & Analytics
- **Time Period Selection**: View data for Week, Month, 3 Months, 6 Months, Year, or All Time
- **Visual Charts**:
  - Category breakdown pie chart
  - Monthly spending trends
- **Statistics**:
  - Total spending
  - Transaction count
  - Daily average spending
  - Top categories

### 🔐 Security Features
- **PIN Authentication**: Set up a 4-digit PIN for app access
- **Biometric Authentication**: 
  - Face ID support (iPhone X and newer)
  - Touch ID support (iPhone 8 and older)
- **App Lock**: Automatically locks when app goes to background
- **Secure Storage**: PIN encrypted using iOS Keychain

### 🎨 User Interface
- **Modern Design**: Clean, intuitive SwiftUI interface
- **Dark Mode Support**: Seamless light/dark mode switching
- **Smooth Animations**: Polished transitions and interactions
- **Card-Based Layout**: Easy-to-read transaction cards
- **Color-Coded Categories**: Visual category identification

### 📱 Additional Features
- **Pull to Refresh**: Update data with a simple pull gesture
- **Swipe Actions**: Quick delete with swipe gestures
- **Date Picker**: Easy date selection with calendar view
- **Transaction History**: Grouped by date for easy browsing
- **Settings Management**: Customize app behavior and security

## 🛠 Technical Stack

### Frameworks & Technologies
- **SwiftUI**: Modern declarative UI framework
- **Realm**: Fast, efficient local database
- **Combine**: Reactive programming for data flow
- **LocalAuthentication**: Face ID / Touch ID integration
- **Keychain Services**: Secure credential storage

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Repository Pattern**: Abstracted data access layer
- **Service Layer**: Reusable business logic
- **Dependency Injection**: Singleton services

### Key Components
```
Expense_Tracking_App/
├── Models/              # Data models and Realm objects
├── ViewModels/          # Business logic and state management
├── Views/               # SwiftUI views
│   ├── Authentication/  # PIN and biometric auth
│   ├── Expense/         # Add/Edit expense screens
│   ├── Transaction/     # Transaction history
│   ├── Reports/         # Analytics and charts
│   ├── Category/        # Category management
│   └── Settings/        # App settings
├── Services/            # Business services
│   ├── RealmManager     # Database operations
│   ├── BiometricAuth    # Face ID / Touch ID
│   └── EncryptionService # PIN encryption
└── Utilities/           # Constants, validators, extensions
```

## 📋 Requirements

- **iOS**: 16.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone or iPad

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Expense_Tracking_App
   ```

2. **Install Dependencies**
   - Open the project in Xcode
   - Go to `File → Add Package Dependencies`
   - Add Realm Swift package:
     - URL: `https://github.com/realm/realm-swift.git`
     - Version: `10.0.0` (Up to Next Major)
     - Select **RealmSwift** only

3. **Configure Info.plist**
   - Ensure `Expense-Tracking-App-Info.plist` exists in project root
   - Face ID usage description is already configured

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## 📱 Usage

### First Launch
1. App opens to the main dashboard
2. Tap "+" to add your first expense
3. Optional: Set up PIN or biometric authentication in Settings

### Adding an Expense
1. Tap the "+" button on the main screen
2. Enter amount, description, and select category
3. Choose date (defaults to today)
4. Tap "Save"

### Viewing Reports
1. Navigate to "Reports" tab
2. Select time period (Week, Month, etc.)
3. View charts and statistics
4. Scroll to see detailed breakdowns

### Setting Up Security
1. Go to "Settings" tab
2. Toggle "PIN Authentication"
3. Create a 4-digit PIN
4. Optional: Enable Face ID / Touch ID

## 🎯 Predefined Categories

- 🍔 **Food & Dining**: Restaurants, groceries, snacks
- 🚗 **Transportation**: Gas, public transit, parking
- 🏠 **Housing**: Rent, utilities, maintenance
- 🎬 **Entertainment**: Movies, games, hobbies
- 🏥 **Healthcare**: Medical, pharmacy, insurance
- 📚 **Education**: Books, courses, tuition
- 👕 **Shopping**: Clothes, electronics, gifts
- 💰 **Bills**: Phone, internet, subscriptions
- ✈️ **Travel**: Flights, hotels, vacation
- 📦 **Other**: Miscellaneous expenses

## 🔧 Configuration

### Database
- **Location**: Realm default directory
- **Schema Version**: 1
- **Migration**: Automatic handling

### Security
- **PIN Length**: 4 digits
- **Storage**: iOS Keychain
- **Biometric**: LocalAuthentication framework

### UI Constants
- **Primary Color**: Purple (#667eea)
- **Secondary Color**: Blue (#764ba2)
- **Spacing**: 8pt, 12pt, 16pt, 24pt
- **Corner Radius**: 8pt, 12pt, 16pt

## 🐛 Troubleshooting

### Common Issues

**1. Realm Package Not Found**
- Solution: Remove and re-add Realm package
- Ensure only `RealmSwift` is selected, not `Realm`

**2. Build Errors**
- Clean build folder: `Product → Clean Build Folder` (Cmd+Shift+K)
- Rebuild: `Product → Build` (Cmd+B)

**3. Face ID Not Working**
- Check Info.plist has Face ID usage description
- Ensure device supports Face ID
- Check Settings → Face ID & Passcode

**4. Data Not Updating**
- Pull to refresh on transaction list
- Check filter/sort settings
- Verify Realm database is accessible

## 📄 License

This project is created for educational and personal use.

## 👨‍💻 Development

### Code Style
- SwiftUI best practices
- MVVM architecture
- Descriptive variable names
- Comprehensive comments

### Testing
- Manual testing on iOS devices
- Simulator testing for UI
- Realm database verification

## 🔄 Recent Updates

### Latest Changes
- ✅ Implemented launch screen
- ✅ Fixed sorting and filtering issues
- ✅ Added period selector for reports
- ✅ Fixed edit transaction sheet
- ✅ Improved PIN setup flow
- ✅ Enhanced data refresh mechanisms

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review code comments
3. Check Realm and SwiftUI documentation

## 🙏 Acknowledgments

- **Realm**: For the excellent mobile database
- **Apple**: For SwiftUI and LocalAuthentication frameworks
- **SF Symbols**: For beautiful system icons

---

**Built with ❤️ using SwiftUI**
