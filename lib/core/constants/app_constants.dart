import 'package:material_ui/material_ui.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'MediNotes';
  static const String appTagline = 'Your Personal Medical Records & Doctor Directory';

  // Blood types
  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  // Sex options
  static const List<String> sexOptions = [
    'Male',
    'Female',
    'Other',
  ];

  // Seeded Category Definitions
  static const List<Map<String, dynamic>> defaultCategories = [
    {'id': 1, 'name': 'Prescriptions', 'icon': 'medication'},
    {'id': 2, 'name': 'Lab Results', 'icon': 'science'},
    {'id': 3, 'name': 'Imaging & Scans', 'icon': 'image'},
    {'id': 4, 'name': 'Vaccinations', 'icon': 'vaccines'},
    {'id': 5, 'name': 'Clinical Notes', 'icon': 'description'},
    {'id': 6, 'name': 'General', 'icon': 'folder'},
  ];

  // Doctor specialties for filtering
  static const List<String> doctorSpecialties = [
    'All',
    'General Medicine',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Orthopedics',
    'Neurology',
    'Ophthalmology',
    'ENT',
  ];

  // Helper to map category icon name to IconData
  static IconData getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'medication':
      case 'prescription':
      case 'prescriptions':
        return Icons.medication_rounded;
      case 'science':
      case 'lab':
      case 'lab results':
        return Icons.science_rounded;
      case 'image':
      case 'imaging':
      case 'imaging & scans':
        return Icons.medical_services_rounded;
      case 'vaccines':
      case 'vaccine':
      case 'vaccinations':
        return Icons.vaccines_rounded;
      case 'description':
      case 'clinical notes':
        return Icons.description_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}
