class ApiConstants {
  static const String baseUrl =
      'https://learn.smktelkom-mlg.sch.id/coworking';

  static const String makerKey = 'mk_fb696f19a77243f88b87592080b7bb6d';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String memberRegister = '/api/auth/register/member';
  static const String adminRegister = '/api/auth/register/admin-space';
  static const String profile = '/api/auth/profile';

  // Space Endpoints
  static const String spaces = '/api/spaces';
  static const String spaceTypes = '/api/spaces/types';
  static const String spaceAvailability = '/api/spaces/availability';
  static String spaceDetail(int id) => '/api/spaces/$id';

  // Diskon Endpoints
  static const String diskonActive = '/api/diskon/active';
  static const String diskonCheck = '/api/diskon/check';
  static String diskonDetail(int id) => '/api/diskon/$id';

  // Reservation Endpoints (Member)
  static const String reservations = '/api/reservasi';
  static const String myReservations = '/api/reservasi/my';
  static const String myHistory = '/api/reservasi/my/history';
  static String reservationDetail(int id) => '/api/reservasi/$id';
  static String reservationETicket(int id) => '/api/reservasi/$id/e-ticket';
  static String cancelReservation(int id) => '/api/reservasi/$id/cancel';

  // Admin Endpoints
  static const String adminProfile = '/api/admin/profile';
  static const String adminMembers = '/api/admin/members';
  static String adminMemberDetail(int id) => '/api/admin/members/$id';
  static const String adminSpaces = '/api/admin/spaces';
  static String adminSpaceDetail(int id) => '/api/admin/spaces/$id';
  static const String adminDiskon = '/api/admin/diskon';
  static String adminDiskonDetail(int id) => '/api/admin/diskon/$id';
  static const String adminReservations = '/api/admin/reservasi';
  static String adminUpdateReservationStatus(int id) =>
      '/api/admin/reservasi/$id/status';
  static String adminCheckIn(int id) => '/api/admin/reservasi/$id/check-in';
  static String adminCheckOut(int id) => '/api/admin/reservasi/$id/check-out';
  static const String adminReportsMonthly = '/api/admin/reports/monthly';
  static const String adminReportsIncome = '/api/admin/reports/income';

  // Upload Endpoints
  static const String uploadImage = '/api/upload/image';
  static const String uploadSpaces = '/api/upload/spaces';
  static const String uploadMembers = '/api/upload/members';
}
