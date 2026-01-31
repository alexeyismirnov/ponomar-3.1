# Flutter Orthodox Church Calendar App - Code Review Report

**Date:** 2026-01-30  
**Files Analyzed:** 47 Dart files in lib/  
**Review Focus:** Bugs, Resource Leaks, Memory Leaks, Performance Issues, Security Concerns

> **Note:** This file contains HIGH and MEDIUM priority issues that require immediate or near-term attention. For style issues, documentation gaps, non-parameterized SQL queries, and other low priority items, see [CODE_REVIEW_LOW_PRIORITY.md](CODE_REVIEW_LOW_PRIORITY.md).

---

## Executive Summary

This is a comprehensive code review of a Flutter Orthodox church calendar application. The codebase is generally well-structured but contains several critical bugs, potential null safety issues, and areas for improvement in error handling, resource management, and code organization.

### Critical Issues Found
- **15+ Potential Runtime Errors** (null pointer exceptions, unchecked casts)
- **Resource Leaks** (database connections not properly closed, stream subscriptions not cancelled)
- **Async/Await Issues** (missing awaits, unhandled futures)
- **Memory Leaks** (unlimited cache growth)

---

## Detailed File Analysis

### 1. lib/audio_player.dart

**Purpose:** Audio player widget for playing audio files with progress tracking.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 14 | Resource Leak | Medium | `AudioPlayer` is not disposed properly - should call `player.dispose()` not just `release()` |
| 23-47 | Stream Subscription Leak | Medium | Stream subscriptions from `onPositionChanged`, `onDurationChanged`, `onPlayerComplete` are never cancelled |
| 63 | Potential Null Error | Low | `Theme.of(context).textTheme.bodyLarge!.color` - uses null assertion operator without check |

---

### 2. lib/bible_model.dart

**Purpose:** Data models for Bible content including Old and New Testament handling.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 36-37 | Unchecked Cast | High | `d["verse"] as int` and `d["text"] as String` - no null/type checking before cast |
| 55 | Null Safety Issue | Medium | `Theme.of(context).textTheme.bodyLarge!.fontFamily!` - double null assertion |
| 63 | Logic Error | Low | `bookName == "ps"` comparison should use constant or enum |
| 76-79 | String Index Error | High | `line.text.substring(0, idx)` and `line.text.substring(idx + 2)` - no bounds checking |
| 123 | Null Assertion | Medium | `Sqflite.firstIntValue(...)!` - assumes query always returns value |
| 169-184 | Null Assertion | High | `pos.index!` and `pos.chapter!` - assumes these are never null |

#### Potential Improvements
- Line 40-47: `fetch()` method should handle database errors and close connections
- Line 112-115: `prepare()` should use `Future.wait()` for parallel processing
- Line 123: Cache database connections instead of opening/closing repeatedly
- Add proper error handling for malformed database data

---

### 3. lib/bible_view.dart

**Purpose:** Bible reading view with language selection dialog.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 46 | Late Initialization | Medium | `late BibleUtil content` - not initialized before use check |
| 54-60 | Unhandled Error | Medium | `getContent()` future error not handled |

#### Potential Improvements
- Line 46: Use nullable type `BibleUtil?` instead of `late`
- Line 54-60: Add error handling for `getContent()`

---

### 4. lib/book_cell.dart

**Purpose:** Widgets for displaying book content (HTML and plain text).

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 63 | Null Assertion | Medium | `Theme.of(context).secondaryHeaderColor.value.toRadixString(16)` - potential null |
| 85-92 | Null Safety | High | `url!` null assertion and `model.getComment(commentId)` result used with `!` |
| 91 | Null Assertion | High | `text!` - assumes comment is never null |

---

### 5. lib/book_model.dart

**Purpose:** Base model classes for book content and positioning.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 19-25 | Null Safety | High | `operator ==` and `hashCode` assume `index` is never null |

#### Potential Improvements
- Line 6-26: `BookPosition` should use nullable types properly or require non-null in constructor
- Line 28-58: Abstract class could benefit from mixin pattern for shared functionality

---

### 6. lib/book_page_multiple.dart

**Purpose:** Multi-page book view with tab navigation.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 24 | Null Assertion | High | `widget.pos.model!` - assumes model is never null |
| 38-51 | Infinite Loop Risk | Medium | While loop depends on `getNextSection()` - could loop forever if logic is broken |
| 79 | Cast Error Risk | Medium | `AsyncSnapshot<dynamic>` - unchecked cast at line 81 |

---

### 7. lib/book_page_single.dart

**Purpose:** Single page book view with bookmark and font size controls.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 36 | Memory Leak | Medium | `setState(() {})` on every scroll event - very inefficient |
| 40-41 | Null Safety | High | `widget.bookmark!` - assumes bookmark is never null when checked |
| 60 | Null Safety | Medium | `ConfigParamExt.bookmarks.val()` could return null |

#### Potential Improvements
- Line 36: Use throttling/debouncing for scroll listener
- Line 39-53: Bookmark operations should handle errors
- Line 114: `ValueKey` using `ConfigParam.fontSize.val()` will cause unnecessary rebuilds

---

### 8. lib/book_toc.dart

**Purpose:** Table of contents view for books.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 36 | Null Assertion | High | `pos.model!.getNumChapters(pos.index!)` - assumes non-null |
| 88-115 | Notification Handler Complexity | Medium | Complex nested if-else with multiple returns |
| 100 | Null Assertion | High | `BookPageMultiple(pos!)` - pos could be null |
| 107-109 | JSON Parsing | Medium | `jsonDecode(json)` without error handling |

---

### 9. lib/bookmarks_model.dart

**Purpose:** Model for managing user bookmarks.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 10 | Static Late | Medium | `static late List<BookModel> books` - must be initialized before use |
| 51 | Exception Handling | Medium | `.first` will throw if no match found - caught but not handled properly |
| 66 | Exception Handling | Medium | Similar issue with `.first` |

#### Potential Improvements
- Line 10: Consider using nullable type or providing default
- Line 44-61: Error handling swallows exceptions - should notify user

---

### 10. lib/calendar_appbar.dart

**Purpose:** Custom app bar with calendar-specific actions.

#### Potential Improvements
- Line 40-93: `_getActions()` builds menu every time - should cache
- Line 41-88: Context menu building is verbose - extract to method

---

### 11. lib/church_calendar.dart

**Purpose:** Core church calendar logic including feast calculations.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 18 | Static Cache | Medium | `static Map<int, ChurchCalendar> calendars` - potential memory leak with unlimited growth |
| 357 | Exception Risk | High | `.first` will throw if no match found |
| 360-368 | Null Safety | High | Multiple `!` assertions on potentially null values |
| 389, 400, 407, 410 | Operator Overload | Medium | `>>` operator usage - clever but confusing |

#### Potential Improvements
- Line 18: Limit cache size or use LRU cache
- Line 52-59: `dateParser` should handle more date formats
- Line 317-323: `paschaDay()` calculation could be extracted to utility class
- Line 356-434: Extension methods are very long - split into logical groups

---

### 12. lib/church_fasting.dart

**Purpose:** Fasting rules and calculations.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 28-39, 41-52, 54-65 | Array Index | Medium | Multiple array accesses by enum index - fragile if enum order changes |
| 99 | Static Cache | Medium | Similar unlimited cache growth issue |
| 175-185 | Async in Sync | High | `await SaintModel(lang).fetch(date)` in else branch - function returns Future but some paths don't await |
| 259-270 | Async in Sync | High | Same issue in `getFastingMonastic` |
| 278-290 | Missing Return | Medium | `meetingOfLord` doesn't cover all code paths explicitly |

#### Potential Improvements
- Line 28-65: Use Map<Enum, Value> instead of array indexing
- Line 111-189: Method is extremely long - split into smaller methods
- Line 191-275: Same issue - very long method

---

### 13. lib/church_reading.dart

**Purpose:** Bible reading calculations for church calendar.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 31 | Mutable State | Medium | `Map<DateTime, List<String>> rr = {}` - mutable state in class |
| 65 | Array Index Risk | High | `gospelMatthew[dayNum]` - no bounds checking |
| 81-88 | Array Index Risk | High | Multiple array accesses without bounds checking |
| 91-101 | Array Index Risk | High | More unbounded array access |
| 184-194 | Null Safety | High | `rr[date]!` and `rr[newDate]!` assume keys exist |
| 198-208 | Null Safety | High | Same issue |

#### Potential Improvements
- Line 34: `models` cache has unlimited growth
- Line 51-54: Array calculations should be validated
- Line 143-149: `generateRR()` builds entire year - could be lazy

---

### 14. lib/day_view.dart

**Purpose:** Main day view showing calendar information.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 85 | Late Initialization | Medium | `late List<SaintIcon> icons` - initialized late |
| 186 | Null Safety | Medium | `JSON.fastingComments[context.countryCode]![fasting.description]` - double lookup could fail |
| 213-215 | State Mutation | Medium | Mutating `icons` in build - anti-pattern |
| 219 | Array Index Risk | Medium | `icons.sublist(page * pageSize, ...)` - could throw if icons empty |
| 264-276 | Widget Building | Medium | Building widgets in loop - acceptable but watch performance |

#### Potential Improvements
- Line 85: Use nullable type instead of late
- Line 174-207: `FutureBuilder` is rebuilt frequently - consider caching
- Line 288-306: Another `FutureBuilder` - consider combining data loading

---

### 15. lib/donations_other.dart

**Purpose:** Donation methods display page.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 9-16 | Hardcoded Values | Medium | All payment details hardcoded - security concern |

#### Potential Improvements
- Line 9-16: Move sensitive data to configuration or secure storage

---

### 16. lib/ebook_model.dart

**Purpose:** E-book content model for SQLite-based books.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 12-30 | Late Fields | Medium | Multiple `late` fields - risk of use before initialization |
| 44-47 | Null Assertions | High | `(await loadString("..."))!` - assumes values exist |
| 49-50 | Null Assertion | High | `Sqflite.firstIntValue(...)!` - assumes query succeeds |
| 82-85 | Null Assertion | Medium | `pos.index!.section` and `pos.index!.index` |
| 88-89 | Null Assertion | Medium | Same issue |
| 92-93 | Null Assertion | High | `Sqflite.firstIntValue(...)!` |

#### Potential Improvements
- Line 40-63: `loadBook()` should handle errors and close DB on failure

---

### 17. lib/feast_notifications.dart

**Purpose:** Sets up notifications for church feasts.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 127-137 | Null Safety | Medium | `d.comment?.isNotEmpty ?? false` and `d.comment!.tr()` - inconsistent |

#### Potential Improvements
- Line 45-137: `setup()` method is very long - split into logical groups
- Line 68-69, 96-125: ForEach with closure - extract to named methods

---

### 18. lib/feofan.dart

**Purpose:** Widget for displaying St. Theophan the Recluse daily thoughts.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 29 | Static Database | Medium | `static Database? db` - shared state |
| 38 | State Mutation | Medium | `savedContent = content` in build method - anti-pattern |
| 67-83 | Null Assertions | High | Multiple `(await getFeofan(...))!` - assumes data exists |
| 85-87 | Array Index | Medium | `(cal.greatLentStart >> date) + 39` - no bounds check |

#### Potential Improvements
- Line 61-119: `fetch()` method is very long
- Line 114-116: Logic for single result is confusing

---

### 19. lib/file_download.dart

**Purpose:** File download dialog with progress indicator.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 46 | Resource Leak | Medium | `http.Client()` not closed on early exit |
| 70-101 | Memory Issue | High | `_bytes` list grows unbounded - for large files could OOM |
| 78-80 | Error Handling | Medium | `onError` sets flag but doesn't prevent `onDone` from running |
| 94-98 | Zip Extraction | Medium | Error caught but only printed - user not notified |

#### Potential Improvements
- Line 70-76: Stream to file directly instead of buffering in memory
- Line 78-80: Error handling could be cleaner
- Line 104-136: Build method could be split

---

### 20. lib/firebase_config.dart

**Purpose:** Firebase and local notification configuration.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 72 | Timezone Issue | Medium | Hardcoded 17:00 time - doesn't account for DST changes properly |

#### Potential Improvements
- Line 23-41: `setup()` should handle initialization errors
- Line 62-90: `schedule()` should validate date is in future
- Line 92-105: `show()` has no error handling

---

### 21. lib/globals.dart

**Purpose:** Global constants, extensions, and utilities.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 17-29 | Static Late | Medium | Multiple `static late` fields - must be initialized before use |

#### Potential Improvements
- Line 17-29: Consider using nullable types or getters with initialization
- Line 31-57: `JSON.load()` should handle errors for each file individually
- Line 97-103: Extension with static fields is unusual pattern

---

### 22. lib/great_lent_full.dart

**Purpose:** Full Great Lent journey view.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 56 | Null Safety | Medium | `snapshot[0]['text']` could be null |

#### Potential Improvements
- Line 44-61: `didChangeDependencies` does heavy work - could be cached
- Line 71-89: Widget building could be extracted

---

### 23. lib/great_lent_short.dart

**Purpose:** Short Great Lent day view widget.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 25-32 | Late Fields | Medium | Multiple `late` fields without null safety |
| 76-88 | Null Safety | Medium | Fields used before initialization check in some paths |

#### Potential Improvements
- Line 25-32: Use nullable types or proper initialization
- Line 64-89: `didChangeDependencies` pattern is complex
- Line 91-127, 129-183: Two large build methods - extract widgets

---

### 24. lib/icon_model.dart

**Purpose:** Model for saint icons.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 17 | Static Database | Medium | `static late Database db` - shared mutable state |

#### Potential Improvements
- Line 24-75: `fetch()` method is long

---

### 25. lib/library_page.dart

**Purpose:** Library page showing available books.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 43-92 | Complex Logic | Medium | Book list building is complex and hardcoded |
| 121-140 | Deep Nesting | Medium | AlertDialog building is deeply nested |
| 144 | Null Safety | Low | `BookPageMultiple(pos)` - pos could be null |

#### Potential Improvements
- Line 43-92: Extract book list to configuration or data file
- Line 96-101: Parallel initialization is good

---

### 26. lib/main_page.dart

**Purpose:** Main page with day view pager.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 57-63 | Async in Sync | Medium | `prepare()` calls not awaited properly |
| 68-72 | Notification Setup | Medium | Only sets up for current year |
| 117 | Null Safety | Medium | `_controller.page!` - could be null |

#### Potential Improvements
- Line 35: Use `WidgetsBinding.instance.addPostFrameCallback`
- Line 50-87: `postInit()` is very long - split into methods

---

### 27. lib/main.dart

**Purpose:** Application entry point.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 31-34 | Version Check | Medium | Logic seems incomplete - cancels notifications but doesn't reschedule |
| 44-56 | Asset Loading | Medium | No error handling for missing assets |

#### Potential Improvements
- Line 16-88: `main()` is very long - extract to initialization service
- Line 44-56: Parallel asset preparation could use `Future.wait`

---

### 28. lib/month_cell.dart

**Purpose:** Individual month calendar cell widget.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 26 | Null Safety | Low | `Theme.of(context).textTheme.titleLarge!.color!` |

#### Potential Improvements
- Line 20-89: FutureBuilder rebuilds frequently - consider caching
- Line 63-74: Container nesting is deep

---

### 29. lib/pericope_model.dart

**Purpose:** Bible pericope (reading passage) parsing and fetching.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 20 | Parsing | Medium | `str.trim().split(" ")` - assumes specific format |
| 43-46 | Array Index | High | `allFilenames.indexOf(filename)` could return -1 |
| 56-65 | Parsing | High | Complex parsing without validation |
| 60 | Cast | Medium | `int.parse(arr4[0])` could throw |
| 68-98 | Database | Medium | Multiple DB calls in loop - N+1 problem |

#### Potential Improvements
- Line 68-98: Batch database queries instead of individual calls
- Line 19-103: `getPericope()` is very long - split into parsing and fetching

---

### 30. lib/pericope.dart

**Purpose:** Widget for displaying pericope readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 30 | Null Safety | Low | `Theme.of(context).textTheme.bodyLarge!.fontFamily!` |
| 92-98 | State in didChangeDependencies | Medium | `currentReading` set in didChangeDependencies |

#### Potential Improvements
- Line 37-75: FutureBuilder is rebuilt frequently
- Line 86-111: `ReadingView` could be separate file

---

### 31. lib/saint_model.dart

**Purpose:** Model for saint data.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 11 | Static Cache | Medium | `static Map<String, Database> databases` - unlimited growth |

#### Potential Improvements
- Line 11: Limit cache size
- Line 25-45: `fetch()` logic is duplicated in parts

---

### 32. lib/saints_lives.dart

**Purpose:** Widget for displaying saints' lives from EPUBs.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 22 | Static Cache | Medium | `static Map<String, SaintsCalendar> calendars` - unlimited growth |
| 28 | Exception Risk | High | `.first` will throw if no match |
| 40-41 | JSON Parsing | Medium | `jsonDecode` without error handling |
| 108 | Null Safety | Medium | `d.comment!` - assumes comment exists |

#### Potential Improvements
- Line 30-80: `loadBook()` is very long
- Line 97-122: `fetch()` could be simplified

---

### 33. lib/story_model.dart

**Purpose:** Model for story/reading content.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 27 | Null Safety | High | `snapshot.first.values.first` - assumes result exists |

#### Potential Improvements
- Line 27: Add null check before accessing result

---

### 34. lib/synaxarion.dart

**Purpose:** Widget for displaying synaxarion readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 41-84 | Date List Building | Medium | Large hardcoded date list in didChangeDependencies |
| 98 | Array Index | Medium | `snapshot[0]` - assumes data exists |

#### Potential Improvements
- Line 41-84: Date list could be pre-calculated or cached
- Line 87-106: `fetch()` could be simplified

---

### 35. lib/taushev.dart

**Purpose:** Widget for displaying Archbishop Averky (Taushev) commentary.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 13 | Model Instantiation | Medium | `final model = EbookModel(...)` created on every build |
| 30 | Array Index | High | `(await getData(id))[0]` - assumes result exists |

#### Potential Improvements
- Line 13: Cache model instance

---

### 36. lib/troparion_model.dart

**Purpose:** Model for troparion and kontakion hymns.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 27 | Static Database | Medium | `static Database? dbFeasts, dbSaints` - shared mutable state |
| 142-157 | Logic Complexity | Medium | Complex nested if logic |
| 163-165 | Error Swallowing | Medium | Catch block just prints error |

#### Potential Improvements
- Line 83-131: `fetchFeast()` logic could be data-driven
- Line 133-168: `fetch()` is very long

---

### 37. lib/troparion_view.dart

**Purpose:** View for displaying troparia and kontakia.

#### Potential Improvements
- Line 19-49: `buildTroparion()` could be separate widget
- Line 51-54: `getContent()` rebuilds on every call

---

### 38. lib/typica_model.dart

**Purpose:** Model for Typika service readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 13-30 | Iterator Implementation | Medium | `TypikaDateIterator` - `moveNext()` always returns true, no end condition |
| 42-79 | Late Fields | Medium | Multiple `late` fields |
| 66-68 | Setter Logic | Medium | `set date` calls async method - unusual pattern |
| 100 | Null Assertion | High | `cal.getTone(date)!` - assumes tone always exists |
| 111-113 | Array Manipulation | Medium | Modifying `prokimen` list after creation - side effects |
| 115 | Array Index | Medium | `.last` on empty list would throw |

#### Potential Improvements
- Line 13-30: Iterator should have proper end condition
- Line 84-96: `loadBook()` should handle errors
- Line 98-116: `setDate()` should handle null tone

---

### 39. lib/year_calendar.dart

**Purpose:** Year calendar view with sharing functionality.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 141-161 | Widget Rebuild | Medium | `getScreenshot()` creates new widget tree |
| 176-184 | Screenshot | Medium | Complex screenshot logic |

#### Potential Improvements
- Line 141-161: Screenshot widget could be cached
- Line 176-189: Extract screenshot logic to service

---

### 40. lib/yungerov.dart

**Purpose:** Model for Yungerov psalter (parallel Church Slavonic/Russian).

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 22-28 | Array Index | Medium | `verses_cs[index]` assumes same length as verses_yu |

#### Potential Improvements
- Line 16-20: Use single query with JOIN
- Line 22-28: Verify arrays have same length

---

### 41. lib/zerna.dart

**Purpose:** Widget for "Zerna" daily readings.

#### Bugs
| Line | Issue | Severity | Description |
|------|-------|----------|-------------|
| 24 | Array Index | Medium | `% numChapters` - assumes numChapters > 0 |

#### Potential Improvements
- Line 17-35: `fetch()` could cache model instance

---

## Summary of Issues by Category

### Critical Bugs (Immediate Attention Required)
1. **Null Pointer Risks** - Excessive use of `!` operator
   - lib/bible_model.dart:36-37, 55, 76-79, 123, 169-184
   - lib/book_cell.dart:63, 85-91
   - lib/book_model.dart:19-25
   - lib/book_page_multiple.dart:24, 36-51
   - lib/church_calendar.dart:357, 360-368
   - lib/church_fasting.dart:175-185, 259-270
   - lib/church_reading.dart:184-208
   - lib/ebook_model.dart:44-50, 66, 82-93
   - lib/feofan.dart:67-83
   - lib/saints_lives.dart:108
   - lib/story_model.dart:27
   - lib/typica_model.dart:100, 115

3. **Resource Leaks**
   - lib/audio_player.dart:14, 23-47 (stream subscriptions)
   - lib/file_download.dart:46 (http client)
   - Multiple database connections not being closed

### Performance Issues
1. **Memory Leaks** - Unlimited cache growth
   - lib/church_calendar.dart:18
   - lib/church_fasting.dart:99
   - lib/church_reading.dart:34
   - lib/icon_model.dart:17
   - lib/saint_model.dart:11
   - lib/saints_lives.dart:22

2. **Inefficient Rebuilds**
   - lib/book_page_single.dart:36 (scroll listener)
   - lib/day_view.dart:174-207, 288-306 (multiple FutureBuilders)

3. **N+1 Query Problems**
   - lib/bible_model.dart:112-115
   - lib/pericope_model.dart:68-98

### Security Issues
1. **Hardcoded Sensitive Data**
   - lib/donations_other.dart:9-16 (payment details)

---

## Recommendations

### Immediate Actions
1. Add proper null safety checks instead of `!` operator
2. Implement resource cleanup (streams, databases, HTTP clients)
3. Add error handling for all async operations

### Short-term Improvements
1. Implement cache size limits
2. Add comprehensive logging instead of print statements
3. Review hardcoded sensitive data (payment details, URLs)

### Long-term Architecture
1. Consider using BLoC or similar state management
2. Implement repository pattern for data access
3. Add unit and integration tests
4. Set up CI/CD with static analysis

---

## Conclusion

The codebase shows signs of organic growth with functionality added over time. While the core logic is sound, there are significant technical debt issues that should be addressed to improve stability and maintainability. The most critical issues are null safety problems (excessive use of `!` operator) and resource leaks, which should be fixed immediately.

For style issues, documentation gaps, non-parameterized SQL queries, and other lower priority items, see [CODE_REVIEW_LOW_PRIORITY.md](CODE_REVIEW_LOW_PRIORITY.md).

**Overall Code Quality Score: 6/10**
- Functionality: 8/10
- Security: 7/10
- Performance: 6/10
- Maintainability: 5/10
- Testability: 4/10
