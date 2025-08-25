# CardApp – Foreign Language Flashcards

A mobile application for learning foreign words using flashcards.  
Built with **Flutter** and available on **Web, Android, and iOS**.

---

## ✨ Features

### 📌 Flashcard Management
- Create flashcards with word pairs (foreign ↔ native)
- Edit and delete flashcards
- Mark flashcards as favorites
- Flip cards to switch display language

### 🗂 Categories
- Create and manage custom categories
- Filter flashcards by category
- Separate category for favorites

### 📥 Import & Export
- Import word lists from files:
  - TXT with delimiters  
  - CSV  
  - Custom format (`word:translation;`)
- Export your collections

### 🧠 Knowledge Testing
- Multiple-choice quiz mode
- Input-based test mode
- Select categories for testing
- Randomized word order
- Track correct/incorrect answers

### 🔍 Search & Filtering
- Full-text search
- Filter by categories
- Show only favorites
- Sort flashcards

### 🎨 User Interface
- English and Russian localization
- Responsive design
- Card flip animations
- Intuitive navigation

---

## 🛠 Technical Details

- **Framework:** Flutter / Dart  
- **Storage:** Hive (local storage)  
- **State Management:** Provider  
- **Architecture:** Clean architecture, service-based business logic  
- **Other:** Async operations, data caching, error handling, unit & widget tests  

---

## 🚀 Installation

```bash
# Clone repository
git clone https://github.com/username/cardApp.git

# Enter project directory
cd cardApp

# Install dependencies
flutter pub get

# Run the app
flutter run
