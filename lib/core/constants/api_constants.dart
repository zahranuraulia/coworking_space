class ApiConstants {
  static const String baseUrl =
      'https://learn.smktelkom-mlg.sch.id/coworking';

  static const String makerKey = 'mk_default_ukk_2026';

  // Auth
  static const String login = '/api/auth/login';
  static const String memberRegister = '/api/auth/register/member';
  static const String adminRegister = '/api/auth/register/admin';
  static const String profile = '/api/auth/profile';

  // Space
  static const String spaces = '/api/spaces';
  static const String spaceAvailability =
      '/api/spaces/availability';

  // Reservation
  static const String reservations = '/api/reservasi';
  static const String myReservations = '/api/reservasi/my';
  static const String myHistory = '/api/reservasi/my/history';

  static String reservationDetail(int id) =>
      '/api/reservasi/$id';

  static String reservationETicket(int id) =>
      '/api/reservasi/$id/e-ticket';
}