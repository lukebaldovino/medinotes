import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medinotes/features/dashboard/screens/dashboard_screen.dart';
import 'package:medinotes/features/doctors/screens/doctor_directory_screen.dart';
import 'package:medinotes/features/navigation/main_navigation_screen.dart';
import 'package:medinotes/features/profile/screens/patient_profile_screen.dart';
import 'package:medinotes/features/records/screens/records_list_screen.dart';
import 'package:medinotes/models/patient.dart';
import 'package:medinotes/providers/doctor_provider.dart';
import 'package:medinotes/providers/patient_provider.dart';
import 'package:medinotes/providers/record_provider.dart';
import 'package:medinotes/providers/visit_provider.dart';
import 'package:provider/provider.dart';

import 'doctors_test.dart';
import 'medical_records_test.dart';
import 'patient_profile_test.dart';
import 'visits_test.dart';

void main() {
  testWidgets('MainNavigationScreen renders and allows tab switching', (WidgetTester tester) async {
    final patientRepo = FakePatientRepository();
    final recordRepo = FakeMedicalRecordRepository();
    final doctorRepo = FakeDoctorRepository();
    final visitRepo = FakeVisitRepository();

    await patientRepo.savePatient(Patient(
      fullName: 'Test Patient',
      birthDate: '1995-05-10',
      sex: 'Female',
      bloodType: 'B+',
      createdAt: '2026-11-18T00:00:00Z',
      updatedAt: '2026-11-18T00:00:00Z',
    ));

    final patientProv = PatientProvider(repository: patientRepo);
    final recordProv = RecordProvider(repository: recordRepo);
    final doctorProv = DoctorProvider(repository: doctorRepo);
    final visitProv = VisitProvider(repository: visitRepo);

    await patientProv.loadProfile();
    await recordProv.initialize();
    await doctorProv.initialize();
    await visitProv.loadVisits();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: patientProv),
          ChangeNotifierProvider.value(value: recordProv),
          ChangeNotifierProvider.value(value: doctorProv),
          ChangeNotifierProvider.value(value: visitProv),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    // Initial tab: Dashboard
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Hello, Test'), findsOneWidget);

    // Tap 'My Records' tab in NavigationBar
    await tester.tap(find.text('My Records'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordsListScreen), findsOneWidget);

    // Tap 'Find Doctors' tab
    await tester.tap(find.text('Find Doctors'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorDirectoryScreen), findsOneWidget);

    // Tap 'Profile' tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientProfileScreen), findsOneWidget);
    expect(find.text('Test Patient'), findsOneWidget);
  });
}
