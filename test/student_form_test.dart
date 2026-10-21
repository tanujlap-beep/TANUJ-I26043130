import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iitu_student_hub/student_form.dart';

void main() {
  testWidgets('StudentFormPortal renders form fields and sections', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StudentFormPortal(
              isDesktop: true,
              isMobile: false,
            ),
          ),
        ),
      ),
    );

    // Verify key titles and sections
    expect(
      find.text('Student Form Submission & Services Hub'),
      findsOneWidget,
    );
    expect(find.text('New Student Application'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Academic Program & Credentials'), findsOneWidget);
    expect(find.text('Guardian & Emergency Contact'), findsOneWidget);
    expect(find.text('Library Membership Details'), findsOneWidget);

    // Verify Tab switching to Submitted Applications
    await tester.tap(find.textContaining('Submitted Applications'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ref: SIST-'), findsAtLeastNWidgets(1));
  });
}
