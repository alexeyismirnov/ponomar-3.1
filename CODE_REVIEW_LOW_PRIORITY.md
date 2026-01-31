# Flutter Orthodox Church Calendar App - Low Priority Code Review Report

**Date:** 2026-01-30  
**Files Analyzed:** 47 Dart files in lib/  
**Review Focus:** Style Issues, Documentation, Minor Improvements, Non-Parameterized SQL Queries

> **Note:** This file contains lower priority issues that are recommended for code quality improvements but do not pose immediate risks to functionality, security, or stability. For critical bugs and high/medium priority issues, see [CODE_REVIEW.md](CODE_REVIEW.md).

---

## Executive Summary

This document contains code quality issues, style inconsistencies, documentation gaps, and non-parameterized SQL queries that should be addressed for maintainability and best practices. These issues are classified as low priority because they either:
- Do not affect runtime behavior
- Involve data from trusted internal sources (not user input)
- Are minor stylistic or organizational improvements

---

## Detailed File Analysis

### 1. lib/audio_player.dart

**Purpose:** Audio player widget for playing audio files with progress tracking.

#### Style Issues
- Line 7: Import ordering - package imports should be separated from local imports with a blank line
- Line 58-91: Inconsistent formatting - some lines use arrow functions, others use block bodies
- Missing documentation comments for public API

#### Potential Improvements
- Line 14: Consider using `AudioPlayer` as a singleton or managing it through a service to avoid multiple instances
- Line 74-77: The logic for checking `currentTime == null` to determine initial play vs resume is fragile
- Add error handling for `player.play()` which can throw exceptions

---

### 2. lib/bible_model.dart

**Purpose:** Data models for Bible content including Old and New Testament handling.

#### Style Issues
- Line 3-11: Import ordering - dart: imports should come before package imports
- Line 26-103: Class `BibleUtil` is doing too much - violates Single Responsibility Principle
- Missing `const` constructors where applicable
- Line 209-248, 250-289: Consider using code generation for repetitive model classes

---

### 3. lib/bible_view.dart

**Purpose:** Bible reading view with language selection dialog.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 14 | Missing Type | Low | `final lang;` - missing explicit type annotation |

#### Potential Improvements
- Line 64: `getTextSpan(context)` is called on every build - consider caching

#### Style Issues
- Line 1-9: Import ordering issues
- Line 27-30: Arrow function could be used for `_getListItem`

---

### 4. lib/book_cell.dart

**Purpose:** Widgets for displaying book content (HTML and plain text).

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 77-78 | Regex Performance | Low | `RegExp` created on every build - should be static |

#### Potential Improvements
- Line 50-56: SVG string should be a static constant
- Line 65-75: CSS string should be extracted to a method or template
- Line 80-93: HTML rendering could be cached

#### Style Issues
- Line 50-56: Inconsistent indentation in multiline string
- Line 45-48: Constructor parameters should use `required` for `model`

---

### 5. lib/book_model.dart

**Purpose:** Base model classes for book content and positioning.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 19 | Covariant Parameter | Low | `covariant BookPosition other` - should consider type safety |

#### Style Issues
- Line 1-3: Import ordering
- Missing documentation for abstract class contract

---

### 6. lib/book_page_multiple.dart

**Purpose:** Multi-page book view with tab navigation.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 115 | DotsIndicator Bug | Low | `position: 0` is hardcoded - should track actual position |

#### Potential Improvements
- Line 38-51: Pre-calculate all positions instead of using while loop
- Line 76-99: Extract FutureBuilder logic to separate widget
- Line 28: `bookPos` list could be final

#### Style Issues
- Line 1-12: Import ordering
- Line 68-123: Build method is too long - should be refactored

---

### 7. lib/book_page_single.dart

**Purpose:** Single page book view with bookmark and font size controls.

#### Style Issues
- Line 7: Typedef should be in separate file or use standard typedef
- Line 18-24: Constructor formatting is inconsistent

---

### 8. lib/book_toc.dart

**Purpose:** Table of contents view for books.

#### Potential Improvements
- Line 86-115: Extract notification handling to separate method
- Line 142: `const Icon(null)` is unusual - should use `SizedBox.shrink()` or hide differently

#### Style Issues
- Line 17-25: Private widget class should be in separate file
- Line 165-182: Build method is long and complex

---

### 9. lib/bookmarks_model.dart

**Purpose:** Model for managing user bookmarks.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 56 | Print Statement | Low | `print(e)` - should use proper logging |

#### Style Issues
- Line 1-7: Import ordering
- Line 35: Constructor should be const if possible

---

### 10. lib/calendar_appbar.dart

**Purpose:** Custom app bar with calendar-specific actions.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 99-101 | Null Safety | Low | `lang == "cs"` check - fontFamily could be null |
| 117-119 | Async Error | Low | `isAvailable()` could throw - not handled |

#### Potential Improvements
- Line 40-93: `_getActions()` builds menu every time - should cache
- Line 41-88: Context menu building is verbose - extract to method

#### Style Issues
- Line 33-38: Constructor parameters formatting
- Line 95-124: Build method could be split

---

### 11. lib/calendar_selector.dart

**Purpose:** Calendar date selection dialog.

#### Potential Improvements
- Line 28-38: Dialog creation could be extracted to method
- Line 44-52: Year calendar navigation could provide better UX

#### Style Issues
- Line 1-8: Import ordering

---

### 12. lib/church_calendar.dart

**Purpose:** Core church calendar logic including feast calculations.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 70-119 | Date Assignment | Low | Multiple `day("...").date = ...` calls - assumes day() always finds match |
| 123-130 | Closure in Loop | Low | Creating closures in loop - acceptable here but watch for captures |

#### Potential Improvements
- Line 52-59: `dateParser` should handle more date formats
- Line 317-323: `paschaDay()` calculation could be extracted to utility class
- Line 356-434: Extension methods are very long - split into logical groups

#### Style Issues
- Line 1-8: Import ordering
- Line 30-50: Constructor does too much work - consider factory pattern
- Line 68-312: Very long methods - should be split

---

### 13. lib/church_day.dart

**Purpose:** Data model for church feast days.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 24-26 | Array Index Risk | Low | Array access by index - if enum changes, this breaks |
| 57 | Static Function | Low | `_fromJson` is static but references `JSON.dateParser` which is also static |

#### Potential Improvements
- Line 24-26: Use Map instead of array for type name lookup
- Line 45-48: `fromJson` could be const constructor

#### Style Issues
- Line 1-2: Import ordering
- Good use of json_annotation

---

### 14. lib/church_day.g.dart

**Purpose:** Generated code for JSON serialization.

#### Notes
- This is generated code - issues here should be fixed in the source file
- No manual changes recommended

---

### 15. lib/church_fasting.dart

**Purpose:** Fasting rules and calculations.

#### Style Issues
- Line 1-8: Import ordering
- Line 68-86: `FastingModel` class should be in separate file
- Line 320-334: Extension methods for private helpers - consider private methods instead

---

### 16. lib/church_page.dart

**Purpose:** Church information and donations page.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 40-41 | URL Hardcoding | Low | URL hardcoded - should be configurable |
| 40-41 | Launch Mode | Low | `externalNonBrowserApplication` may not work on all devices |

#### Potential Improvements
- Line 16-18: Empty `initState()` - remove or add functionality
- Line 20-61: `getContent()` builds widgets - should be build method or separate widgets

#### Style Issues
- Line 64-73: Inconsistent indentation in build method

---

### 17. lib/church_reading.dart

**Purpose:** Bible reading calculations for church calendar.

#### Style Issues
- Line 1-8: Import ordering
- Line 28-49: Constructor does heavy work - use factory or lazy loading

---

### 18. lib/custom_list_tile.dart

**Purpose:** Custom list tile widget.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 36 | Empty Check | Low | `(subtitle?.length ?? 0) == 0` - could use `isNullOrEmpty` |

#### Potential Improvements
- Line 11-17: Constructor should use `required` for `onTap`
- Line 42-60: Conditional widget building could be extracted

#### Style Issues
- Good overall structure

---

### 19. lib/day_view.dart

**Purpose:** Main day view showing calendar information.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 135 | String Concatenation | Low | Using `+` for strings - prefer interpolation |
| 235-237 | Hardcoded Check | Low | `context.languageCode == 'ru'` - should be configurable |

#### Style Issues
- Line 1-24: Import ordering
- Line 25-65: Private widget should be in separate file
- Line 308-335: Build method is very long

---

### 20. lib/donations_other.dart

**Purpose:** Donation methods display page.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 25-31 | Async Error | Low | `Clipboard.setData` error not handled |

#### Potential Improvements
- Line 18-36: `_listItem` could be a separate widget

#### Style Issues
- Line 9-16: Use camelCase for variable names (currently using snake_case)

---

### 21. lib/ebook_model.dart

**Purpose:** E-book content model for SQLite-based books.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 66 | Non-Parameterized Query | Low | `where: "key='$key'"` - uses string interpolation instead of parameterized query. Note: Data comes from trusted internal sources, not user input, so no immediate security risk. Using parameterized queries is recommended as a best practice for maintainability and future-proofing. |

#### Potential Improvements
- Line 40-63: `loadBook()` should handle errors and close DB on failure
- Line 66: Consider using parameterized queries for consistency and best practices
- Line 75: `items[section]!` - should handle missing key

#### Style Issues
- Line 1-8: Import ordering
- Line 36-38: Constructor doing async work - consider factory pattern

---

### 22. lib/feast_notifications.dart

**Purpose:** Sets up notifications for church feasts.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 128 | Logic Error | Low | `d.name.isEmpty` check - might be intentional but worth verifying |

#### Potential Improvements
- Line 45-137: `setup()` method is very long - split into logical groups
- Line 68-69, 96-125: ForEach with closure - extract to named methods

#### Style Issues
- Line 1-9: Import ordering
- Line 38-43: Date format methods could be cached

---

### 23. lib/feofan.dart

**Purpose:** Widget for displaying St. Theophan the Recluse daily thoughts.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 48-55 | Non-Parameterized Query | Low | `where: "id=\"$id\""` and `where: "id LIKE'%$id'"` - uses string interpolation. Note: Data comes from trusted internal sources (hardcoded IDs, not user input), so no immediate security risk. Using parameterized queries is recommended as a best practice. |

#### Potential Improvements
- Line 48-55: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources
- Line 61-119: `fetch()` method is very long
- Line 114-116: Logic for single result is confusing

#### Style Issues
- Line 1-13: Import ordering
- Line 37: Default parameter value should be const

---

### 24. lib/file_download.dart

**Purpose:** File download dialog with progress indicator.

#### Style Issues
- Line 1-9: Import ordering
- Line 17-34: Constructor formatting

---

### 25. lib/firebase_config.dart

**Purpose:** Firebase and local notification configuration.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 21 | Static Counter | Low | `static var count = 0` - could overflow in theory |
| 64 | Race Condition | Low | `count++` not atomic |

#### Style Issues
- Line 1-8: Import ordering
- Good use of static methods for service class

---

### 26. lib/globals.dart

**Purpose:** Global constants, extensions, and utilities.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 69-70 | Locale Parsing | Low | String splitting for locale - could fail with unexpected format |
| 75-79 | Hex Parsing | Low | No validation of hex string format |

#### Style Issues
- Line 1-12: Import ordering
- Line 105-109: `getRange` could use existing `Iterable.generate`

---

### 27. lib/great_lent_full.dart

**Purpose:** Full Great Lent journey view.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 22-39 | Hardcoded Values | Low | `days` array is hardcoded - should be data-driven |
| 53-54 | Locale Parsing | Low | `context.locale.toString().split("_")` - fragile |

#### Style Issues
- Line 1-12: Import ordering
- Line 66-89: Deep nesting - extract widgets

---

### 28. lib/great_lent_short.dart

**Purpose:** Short Great Lent day view widget.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 34-47 | Hardcoded Values | Low | `days` array hardcoded |
| 92-98 | Container Size | Low | Hardcoded height values |
| 100 | String Logic | Low | Complex string concatenation logic |

#### Style Issues
- Line 1-11: Import ordering
- Line 91-127: `buildShortView` is long
- Line 129-183: `buildLongView` is very long

---

### 29. lib/icon_model.dart

**Purpose:** Model for saint icons.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 28-45 | Hardcoded IDs | Low | Icon IDs hardcoded |
| 50-56 | Non-Parameterized Query | Low | `where: "id=${code.name}"` - string interpolation. Note: Data comes from trusted internal enum values, not user input, so no immediate security risk. |
| 82-86, 89-100 | Non-Parameterized Query | Low | `where: "month=$month AND day=$day"` - string interpolation. Note: Date values come from internal calendar calculations, not user input, so no immediate security risk. |

#### Potential Improvements
- Line 50-56, 82-100: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources
- Line 24-75: `fetch()` method is long

#### Style Issues
- Line 1-7: Import ordering
- Good use of static methods

---

### 30. lib/library_page.dart

**Purpose:** Library page showing available books.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 24-29 | Unused Fields | Low | `date` and `savedDate` declared but not used |

#### Potential Improvements
- Line 43-92: Extract book list to configuration or data file

#### Style Issues
- Line 1-17: Import ordering
- Line 104-162: `getContent()` is very long

---

### 31. lib/main_page.dart

**Purpose:** Main page with day view pager.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 21 | Magic Number | Low | `initialPage = 100000` - should be constant |
| 35 | Post Frame | Low | `Future.delayed(Duration.zero, ...)` - hacky pattern |
| 42-47 | Rate My App | Low | Dialog shown in `didChangeDependencies` - could show multiple times |
| 79-84 | Config Setup | Low | EPUB config in postInit - could fail |
| 103-105 | Date Comparison | Low | `date != DateTime.utc(...)` - time component could cause issues |

#### Style Issues
- Line 1-14: Import ordering
- Line 122-141: Build method has nested closures

---

### 32. lib/main.dart

**Purpose:** Application entry point.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 29 | Naming Mismatch | Low | `'ver_1_3'` stored but field is `ver_1_2` |

#### Style Issues
- Line 1-15: Import ordering
- Line 64-88: Deep nesting in `runApp`

---

### 33. lib/month_cell.dart

**Purpose:** Individual month calendar cell widget.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 33 | Function Call | Low | `Cal.getGreatFeast(date)` called on every build |
| 40-42 | Ternary Complexity | Low | Complex nested ternary |

#### Style Issues
- Line 1-8: Import ordering
- Good widget structure overall

---

### 34. lib/month_info_container.dart

**Purpose:** Month view container with pager.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 19 | Magic Number | Low | `initialPage = 100000` |
| 33-40 | Title Update | Low | Called frequently - could be optimized |
| 59 | State Toggle | Low | `showInfo` toggle causes full rebuild |

#### Style Issues
- Line 1-9: Import ordering
- Line 43-109: Build method is long but acceptable

---

### 35. lib/pericope_model.dart

**Purpose:** Bible pericope (reading passage) parsing and fetching.

#### Style Issues
- Line 1-6: Import ordering
- Line 13-15: Fields should be private

---

### 36. lib/pericope.dart

**Purpose:** Widget for displaying pericope readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 40 | Error Display | Low | `"network error"` - not localized |

#### Style Issues
- Line 1-11: Import ordering
- Line 41: Error message should be translatable

---

### 37. lib/saint_model.dart

**Purpose:** Model for saint data.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 16-18 | String Format | Low | `format()` usage - consider interpolation |
| 48 | Non-Parameterized Query | Low | `where: "day=${d.day}"` - string interpolation. Note: Date values come from internal calendar calculations, not user input, so no immediate security risk. |

#### Potential Improvements
- Line 48: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources

#### Style Issues
- Line 1-7: Import ordering
- Good use of static methods

---

### 38. lib/saints_lives.dart

**Purpose:** Widget for displaying saints' lives from EPUBs.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 48-79 | Date Assignment | Low | Multiple date assignments - similar to church_calendar.dart |

#### Potential Improvements
- Line 30-80: `loadBook()` is very long
- Line 97-122: `fetch()` could be simplified

#### Style Issues
- Line 1-14: Import ordering
- Line 24: Private constructor naming is good

---

### 39. lib/story_model.dart

**Purpose:** Model for story/reading content.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 19 | Non-Parameterized Query | Low | `WHERE id="$id"` - string interpolation. Note: ID comes from trusted internal data, not user input, so no immediate security risk. |
| 23-27 | Non-Parameterized Query | Low | `WHERE key="$key"` - string interpolation. Note: Key comes from trusted internal data, not user input, so no immediate security risk. |
| 34 | Non-Parameterized Query | Low | `WHERE id="$id" AND lang="$lang"` - string interpolation. Note: Values come from trusted internal data, not user input, so no immediate security risk. |

#### Potential Improvements
- Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources

#### Style Issues
- Line 1-3: Import ordering
- Line 9-11: Constructor formatting

---

### 40. lib/synaxarion.dart

**Purpose:** Widget for displaying synaxarion readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 29 | Mutable State | Low | `List<DateTime> dates = []` - mutable |

#### Style Issues
- Line 1-15: Import ordering
- Line 2: Import uses `package:ponomar/book_model.dart` - should be relative

---

### 41. lib/taushev.dart

**Purpose:** Widget for displaying Archbishop Averky (Taushev) commentary.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 17-18 | Non-Parameterized Query | Low | `where: "id=\"$id\""` - string interpolation. Note: ID comes from trusted internal data, not user input, so no immediate security risk. |

#### Potential Improvements
- Line 17-18: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources

#### Style Issues
- Line 1-9: Import ordering
- Line 2: Import uses `package:ponomar` - should be relative

---

### 42. lib/troparion_model.dart

**Purpose:** Model for troparion and kontakion hymns.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 37, 52 | Non-Parameterized Query | Low | `where: "comment=\"$id\""` and `where: "day=${d.day} AND month=${d.month}"` - string interpolation. Note: Values come from trusted internal data (feast codes, calendar dates), not user input, so no immediate security risk. |
| 85-125 | Hardcoded List | Low | `feastsCodes` array is hardcoded |

#### Potential Improvements
- Line 37, 52: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources
- Line 83-131: `fetchFeast()` logic could be data-driven
- Line 133-168: `fetch()` is very long

#### Style Issues
- Line 1-11: Import ordering
- Line 12-22: `Troparion` class should be in separate file

---

### 43. lib/troparion_view.dart

**Purpose:** View for displaying troparia and kontakia.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 20 | Null Safety | Low | `ConfigParam.fontSize.val()` - assumes initialized |
| 24 | Empty Check | Low | `t.glas ?? ""` - could use null-aware operator differently |

#### Potential Improvements
- Line 19-49: `buildTroparion()` could be separate widget
- Line 51-54: `getContent()` rebuilds on every call

#### Style Issues
- Line 1-7: Import ordering
- Good widget structure

---

### 44. lib/typica_model.dart

**Purpose:** Model for Typika service readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 118-119 | Non-Parameterized Query | Low | `where: "key='$key'"` - string interpolation. Note: Key comes from trusted internal data, not user input, so no immediate security risk. |
| 137-151 | String Replacement | Low | Multiple string replacements - could be optimized |

#### Potential Improvements
- Line 118-119: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources

#### Style Issues
- Line 1-12: Import ordering
- Line 2: Import uses `package:ponomar` - should be relative

---

### 45. lib/year_calendar.dart

**Purpose:** Year calendar view with sharing functionality.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 115 | Magic Number | Low | `initialPage = 100000` |
| 174 | Debug Print | Low | `print(path)` - should be removed |

#### Style Issues
- Line 1-18: Import ordering
- Line 163-197: `getAppbar()` could be separate widget

---

### 46. lib/yungerov.dart

**Purpose:** Model for Yungerov psalter (parallel Church Slavonic/Russian).

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 12 | Non-Parameterized Query | Low | `where: "psalm=?"` is good, but line 19 uses string format. Note: Values come from trusted internal data, not user input, so no immediate security risk. |
| 16-20 | SQL Queries | Low | Two separate queries - could be joined |
| 27 | String Building | Low | HTML string building in loop - inefficient |

#### Potential Improvements
- Line 12, 19: Consider using parameterized queries for consistency and best practices, though current implementation poses no security risk as data comes from trusted internal sources
- Line 16-20: Use single query with JOIN

#### Style Issues
- Line 1-5: Import ordering
- Line 6-8: Class should have documentation

---

### 47. lib/zerna.dart

**Purpose:** Widget for "Zerna" daily readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 24 | Date Math | Low | `(startDate >> date)` - using custom operator |

#### Style Issues
- Line 1-12: Import ordering
- Line 2: Import uses `package:ponomar` - should be relative

---

## Summary of Issues by Category

### Non-Parameterized SQL Queries (Code Quality Best Practices)
Multiple files use string interpolation in SQL queries instead of parameterized queries. **Note:** These do not pose immediate security risks as all data comes from trusted internal sources (hardcoded values, internal calculations, or enum values), not from user input. However, using parameterized queries is recommended for:
- Code consistency and maintainability
- Future-proofing against potential changes
- Following established best practices

Files affected:
- lib/ebook_model.dart:66
- lib/feofan.dart:48-55
- lib/icon_model.dart:50-56, 82-100
- lib/saint_model.dart:48
- lib/story_model.dart:19, 23-27, 34
- lib/taushev.dart:17-18
- lib/troparion_model.dart:37, 52
- lib/typica_model.dart:118-119
- lib/yungerov.dart:12, 19

### Code Style Issues
1. **Import Ordering** - Most files have inconsistent import ordering
2. **Long Methods** - Many methods exceed 50 lines
3. **Deep Nesting** - Complex nested if/else structures
4. **Missing Documentation** - Public APIs lack documentation
5. **Inconsistent Formatting** - Constructor formatting, indentation

### Minor Improvements
1. **Hardcoded Values** - Many arrays and values are hardcoded instead of data-driven
2. **Magic Numbers** - Multiple uses of `100000` for initial page
3. **Print Statements** - Debug print statements should use proper logging
4. **String Building** - Inefficient string concatenation in loops

---

## Recommendations

### Code Quality Improvements
1. Standardize import ordering across all files
2. Add documentation comments for public APIs
3. Refactor long methods into smaller, testable units
4. Extract widgets to separate files
5. Consider using parameterized queries for SQL operations (currently low priority as data comes from trusted internal sources)

### Short-term Improvements
1. Replace magic numbers with named constants
2. Add comprehensive logging instead of print statements
3. Standardize naming conventions (camelCase vs snake_case)
4. Make hardcoded arrays data-driven where appropriate

### Long-term Architecture
1. Consider using BLoC or similar state management
2. Implement repository pattern for data access
3. Add unit and integration tests
4. Set up CI/CD with static analysis

---

## Conclusion

The issues in this document represent opportunities for code quality improvements and best practice adherence. While they do not pose immediate risks to functionality or security, addressing them will improve maintainability, readability, and future-proof the codebase. The SQL queries using string interpolation do not pose immediate security risks as all data comes from trusted internal sources, though using parameterized queries remains a recommended best practice for code quality.

**Overall Code Quality Score: 6/10**
- Functionality: 8/10
- Security: 7/10
- Performance: 6/10
- Maintainability: 5/10
- Testability: 4/10
