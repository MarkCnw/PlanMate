// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:planmate/CreateProject/presentation/project_screen.dart';


// void main() {
//   group('Delete Confirmation Dialog Tests', () {
//     late FakeFirebaseFirestore fakeFirestore;
//     const testProjectId = 'project1';
//     const testProjectName = 'My Test Project';

//     setUp(() {
//       fakeFirestore = FakeFirebaseFirestore();
//       // เตรียมข้อมูลโปรเจกต์ (หาก widget เรียกอ่านก่อนลบ)
//       fakeFirestore.collection('projects').doc(testProjectId).set({
//         'name': testProjectName,
//       });
//     });

//     Future<void> pumpWidget(WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: ShowProjectScreen(
//             projectId: testProjectId,
//             projectName: testProjectName,
//             firestore: fakeFirestore, // inject fake firestore
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();
//     }

//     testWidgets('should show loading state when deleting', (tester) async {
//       await pumpWidget(tester);

//       // เปิด dialog
//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();

//       // กดปุ่ม Delete ใน dialog
//       await tester.tap(find.text('Delete', skipOffstage: false).last);
//       await tester.pump(); // เริ่ม loading ให้ติดขึ้น
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//       expect(find.text('Deleting project...'), findsOneWidget);

//       // รอให้ delete operation เสร็จสมบูรณ์
//       await tester.pump(const Duration(milliseconds: 500));
//       await tester.pumpAndSettle();
//     });

//     testWidgets('should show success snackbar after successful deletion', (tester) async {
//       await pumpWidget(tester);

//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('Delete', skipOffstage: false).last);
//       await tester.pump(); // show loading
//       await tester.pump(const Duration(milliseconds: 500));
//       await tester.pumpAndSettle();

//       // snackbar ควรปรากฏ
//       expect(find.text('Project deleted successfully'), findsOneWidget);
//       // ตรวจสอบว่า document ถูกลบจาก fakeFirestore
//       final snapshot = await fakeFirestore.collection('projects').get();
//       expect(snapshot.docs.where((d) => d.id == testProjectId), isEmpty);
//     });

//     testWidgets('should disable dismiss barrier during deletion', (tester) async {
//       await pumpWidget(tester);

//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();
//       await tester.tap(find.text('Delete', skipOffstage: false).last);
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 100));

//       // ลอง tap ฉากหลังเพื่อ dismiss แต่ไม่ควรปิด
//       await tester.tapAt(Offset(10, 10));
//       await tester.pump(const Duration(milliseconds: 100));
//       expect(find.byType(AlertDialog), findsOneWidget);

//       // รอจนเสร็จ
//       await tester.pump(const Duration(milliseconds: 400));
//       await tester.pumpAndSettle();
//     });

//     testWidgets('should handle project name with quotes correctly', (tester) async {
//       const weirdName = 'My "Special" Project & More';
//       await fakeFirestore.collection('projects').doc(testProjectId).set({
//         'name': weirdName,
//       });
//       await pumpWidget(tester);

//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();

//       // ข้อความใน dialog ต้องมีชื่อโปรเจกต์เดียวเท่านั้น
//       final confirmWithinAlert = find.descendant(
//         of: find.byType(AlertDialog),
//         matching: find.textContaining(weirdName),
//       );
//       expect(confirmWithinAlert, findsOneWidget);
//     });

//     testWidgets('should handle very long project names', (tester) async {
//       const longName = 'This is a very long project name that might cause layout issues if not handled properly';
//       await fakeFirestore.collection('projects').doc(testProjectId).set({
//         'name': longName,
//       });
//       await pumpWidget(tester);

//       await tester.tap(find.text('Delete'));
//       await tester.pumpAndSettle();

//       final confirmWithinAlert = find.descendant(
//         of: find.byType(AlertDialog),
//         matching: find.textContaining(longName),
//       );
//       expect(confirmWithinAlert, findsOneWidget);
//     });
//   });
// }
