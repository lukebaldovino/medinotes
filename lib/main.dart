import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_helper.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'providers/doctor_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/record_provider.dart';
import 'providers/visit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database and verify tables / seeds
  await DatabaseHelper.instance.database;

  runApp(const MediNotesApp());
}

class MediNotesApp extends StatelessWidget {
  const MediNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PatientProvider()..loadProfile(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecordProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => VisitProvider()..loadVisits(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            centerTitle: false,
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}
