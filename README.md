CardApp – Foreign Language Flashcards

A mobile application for learning foreign words using flashcards.
Developed in Flutter, available on Web, Android, and iOS.

Main Features
Flashcard Management

Create flashcards with word pairs (foreign ↔ native)

Edit existing flashcards

Delete flashcards

Mark flashcards as favorites

Flip cards (switch display language)

Categories

Create custom categories to group words

Manage categories (add/delete)

Filter flashcards by category

Separate category for favorite words

Import & Export

Import word lists from text files

Supported formats:

TXT files with delimiters

CSV files

Custom format (word:translation;)

Knowledge Testing

Two test modes:

Multiple choice quiz

Input-based test

Select category for testing

Random word order

Track correct/incorrect answers

Search & Filtering

Search by words

Filter by categories

Show only favorite words

Sort flashcards

User Interface

Light/Dark theme support

Localization (English/Russian)

Responsive design

Card animations

Easy navigation

Technical Details
Architecture

Flutter/Dart

Hive for local storage

Provider for state management

Clean architecture

Separate services for business logic

Implementation Highlights

Asynchronous operations

Data caching

Optimized performance

Error handling

Unit & widget tests

Installation
# Clone repository
git clone https://github.com/username/cardApp.git

# Enter project directory
cd cardApp

# Install dependencies
flutter pub get

# Run the app
flutter run

Changelog (Today’s Updates)
1. New HomeScreenWidgets Class

Extracted UI components into a separate class

Improved code organization

Added all required widget builder methods

2. New Methods in HomeScreenWidgets
- buildLanguageMenu()
- buildUploadButton()
- buildTestButton()
- buildFlipButton()
- buildAddButton()
- buildSearchField()
- buildCardList()
- buildDrawerHeader()
- buildCategoryItems()
- buildDefaultDrawerItems()

3. Improvements in HomeScreen

Refactored code structure

Added MARK comments for navigation

Improved service/data initialization

Added flipAllCards() method

Organized imports by category

4. Async Operations Fixes

Added await where required

Fixed return types in service methods

Improved error handling

5. State Management Improvements

Moved widget initialization into build

Fixed UI updates on data changes

Improved category & card handling

6. Added Dialog Files
- add_word_dialog.dart
- add_word_list_dialog.dart
- edit_card_dialog.dart
- category_dialog.dart
- test_dialog.dart

7. Feature Enhancements

Add single word

Add word list

Import words from file

Manage categories

Search flashcards

Switch languages

Test flashcards

8. Bug Fixes

Fixed DDS issue on startup

Fixed void return type errors

Fixed category updates

Fixed context handling

9. UI Improvements

Added notifications (SnackBar)

Improved dialogs look & feel

Added action icons

Enhanced category navigation

10. Performance Optimization

Reduced widget rebuilds

Optimized state management

Improved async handling
