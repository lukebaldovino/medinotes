class DatabaseTables {
  DatabaseTables._();

  // Patients Table
  static const String tablePatients = 'patients';
  static const String colPatientId = 'id';
  static const String colPatientFullName = 'full_name';
  static const String colPatientBirthDate = 'birth_date';
  static const String colPatientSex = 'sex';
  static const String colPatientBloodType = 'blood_type';
  static const String colPatientContactNumber = 'contact_number';
  static const String colPatientEmergencyContact = 'emergency_contact';
  static const String colPatientAllergies = 'allergies';
  static const String colPatientCreatedAt = 'created_at';
  static const String colPatientUpdatedAt = 'updated_at';

  // Record Categories Table
  static const String tableRecordCategories = 'record_categories';
  static const String colCategoryId = 'id';
  static const String colCategoryName = 'name';
  static const String colCategoryIcon = 'icon';

  // Medical Records Table
  static const String tableMedicalRecords = 'medical_records';
  static const String colRecordId = 'id';
  static const String colRecordTitle = 'title';
  static const String colRecordCategoryId = 'category_id';
  static const String colRecordDescription = 'description';
  static const String colRecordDate = 'record_date';
  static const String colRecordDoctorName = 'doctor_name';
  static const String colRecordFacilityName = 'facility_name';
  static const String colRecordFilePath = 'file_path';
  static const String colRecordFileType = 'file_type';
  static const String colRecordCreatedAt = 'created_at';
  static const String colRecordUpdatedAt = 'updated_at';

  // Doctors Table
  static const String tableDoctors = 'doctors';
  static const String colDoctorId = 'id';
  static const String colDoctorFullName = 'full_name';
  static const String colDoctorSpecialty = 'specialty';
  static const String colDoctorClinicName = 'clinic_name';
  static const String colDoctorAddress = 'address';
  static const String colDoctorContactNumber = 'contact_number';
  static const String colDoctorDescription = 'description';
  static const String colDoctorImagePath = 'image_path';
  static const String colDoctorIsFavorite = 'is_favorite';

  // Visits Table
  static const String tableVisits = 'visits';
  static const String colVisitId = 'id';
  static const String colVisitDoctorId = 'doctor_id';
  static const String colVisitDate = 'visit_date';
  static const String colVisitReason = 'reason';
  static const String colVisitDiagnosis = 'diagnosis';
  static const String colVisitNotes = 'notes';
  static const String colVisitCreatedAt = 'created_at';
}
