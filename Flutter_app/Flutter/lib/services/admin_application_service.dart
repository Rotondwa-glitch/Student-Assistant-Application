
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApplicationService {
  final SupabaseClient _client;

  AdminApplicationService(this._client);

  /// Update application status and eligibility.
  Future<void> updateApplicationStatus(
    String applicationId,
    String newStatus,
  ) async {
    // Update the application status.
    // Supabase throws an exception if the update fails.
    await _client
        .from('applications')
        .update({'status': newStatus})
        .eq('application_id', applicationId);

    // Update eligibility based on the new status.
    if (newStatus.toLowerCase() == 'approved') {
      await _updateEligibility(applicationId, true);
    } else if (newStatus.toLowerCase() == 'rejected') {
      await _updateEligibility(applicationId, false);
    }
  }

  /// Update eligibility in the students table.
  Future<void> _updateEligibility(
    String applicationId,
    bool isEligible,
  ) async {
    // Fetch the student ID associated with the application.
    final appRow = await _client
        .from('applications')
        .select('student_id')
        .eq('application_id', applicationId)
        .single();

    final studentId = appRow['student_id'];

    // Update the student's eligibility.
    await _client
        .from('students')
        .update({'eligible': isEligible})
        .eq('student_id', studentId);
  }
}
