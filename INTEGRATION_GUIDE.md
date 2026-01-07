# Integration Guide - Teacher & Student Dashboard

## Quick Start Integration

This guide shows how to integrate the new Teacher & Student Dashboard features into your existing app navigation.

---

## 1. Update Student Login Flow

**File**: `lib/screens/student/student_login_screen.dart`

Replace the navigation after successful login with:

```dart
// After successful login, navigate to Student Dashboard
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => StudentDashboard(student: student),
  ),
);
```

Instead of the existing `StudentResultsScreen`, use the new `StudentDashboard` which includes Results, Recordings, and Papers tabs.

---

## 2. Update Teacher Navigation

**File**: `lib/screens/teacher/teacher_dashboard.dart`

The dashboard is already updated with:
- Classrooms Tab (existing functionality)
- Recordings Tab (new)
- Papers Tab (new)

No additional changes needed - it's ready to use!

---

## 3. Add url_launcher Dependency

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.4
```

Then run:
```bash
flutter pub get
```

This is required for:
- Opening YouTube links on mobile/web
- Downloading PDF files

---

## 4. Firebase Security Rules (Optional)

Add these Firestore rules to secure your collections:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Existing rules...
    
    // Lesson Recordings - Teachers can read/write own, students can read all
    match /lesson_recordings/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.teacherId;
    }
    
    // Exam Papers - Teachers can read/write own, students can read all
    match /exam_papers/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.teacherId;
    }
  }
}
```

---

## 5. Test the Features

### Teacher Testing:
1. ✅ Login as teacher
2. ✅ Click on "Recordings" tab
3. ✅ Click FAB to upload recording
4. ✅ Fill in all fields and submit
5. ✅ Recording should appear in the list
6. ✅ Test delete functionality
7. ✅ Repeat for Papers tab

### Student Testing:
1. ✅ Login with student index number
2. ✅ Switch to "Recordings" tab
3. ✅ Select a grade and subject
4. ✅ Click "Watch on YouTube" button
5. ✅ Verify YouTube opens
6. ✅ Go to "Papers" tab
7. ✅ Select grade, subject, and term
8. ✅ Click "Download PDF" button
9. ✅ Verify PDF opens/downloads

---

## 6. File Structure

```
lib/
├── models/
│   └── models.dart (Updated - added LessonRecording, ExamPaper)
├── services/
│   ├── firestore_service.dart (Existing)
│   └── lesson_paper_service.dart (NEW)
├── screens/
│   ├── teacher/
│   │   ├── teacher_dashboard.dart (Updated - added tabs)
│   │   ├── teacher_upload_recording.dart (NEW)
│   │   ├── teacher_upload_paper.dart (NEW)
│   │   └── exam_marks_entry_screen.dart (Existing)
│   └── student/
│       ├── student_dashboard.dart (NEW)
│       ├── student_watch_recordings.dart (NEW)
│       ├── student_download_papers.dart (NEW)
│       └── student_results_screen.dart (Existing - used in dashboard)
└── main.dart (No changes needed)
```

---

## 7. Key Imports

Make sure these imports are available in your files:

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
```

---

## 8. Environment Setup

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
  firebase_auth: ^5.3.1
  provider: ^6.1.2
  url_launcher: ^6.2.4
  cupertino_icons: ^1.0.8
  flutter_spinkit: ^5.2.1
  intl: ^0.19.0
  flutter_platform_widgets: ^7.0.1
```

Run: `flutter pub get`

---

## 9. Firestore Collections Auto-Creation

The collections will be created automatically when first data is inserted:
- `lesson_recordings`
- `exam_papers`

No manual collection creation needed!

---

## 10. Important Notes

1. **YouTube Links**: Make sure teachers provide valid YouTube URLs (containing "youtube.com")
2. **File URLs**: For papers, teachers should provide valid PDF URLs
3. **Grade/Subject Sync**: Make sure grades and subjects are properly set up in your `grades` and `subjects` collections
4. **Classroom Setup**: Ensure classrooms are set up correctly for teachers to have proper access to grades/subjects

---

## 11. Troubleshooting

### Issue: "No recordings found"
**Solution**: Make sure the teacher has uploaded recordings for that grade/subject

### Issue: YouTube link not opening
**Solution**: Check that the URL contains "youtube.com" and is valid

### Issue: "File not found" when downloading
**Solution**: Verify the PDF URL is accessible and valid

### Issue: No grades showing
**Solution**: Ensure grades are created in the `grades` collection

---

## 12. Future Customizations

### To add file upload instead of URLs:
1. Add Firebase Storage to your project
2. Create a file picker UI
3. Upload file to Storage and get download URL
4. Save URL to Firestore

### To add email notifications:
1. Implement Firestore Cloud Functions
2. Send emails when new content is uploaded

### To add content categories:
Add `category` field to models and filter accordingly

---

## Support

For issues or questions:
1. Check Firestore console for data integrity
2. Verify teacher IDs match in classrooms
3. Check browser console (web) for JavaScript errors
4. Check Flutter debug console for errors

---

**Last Updated**: December 24, 2025  
**Status**: Ready for Production
