import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/e_ticket.dart';

class ETicketService {
  final ApiClient _apiClient = ApiClient();

  Future<ETicket> getETicket(int reservationId) async {
    final response = await _apiClient.get(
      ApiConstants.reservationETicket(reservationId),
    );

    final responseData = response.data as Map<String, dynamic>;

    return ETicket.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }
}