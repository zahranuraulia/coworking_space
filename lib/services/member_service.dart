import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/member.dart';

class MemberService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Member>> getMembers({String? search}) async {
    final response = await _apiClient.get(
      ApiConstants.adminMembers,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final list = (response.data['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Member> getMemberDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.adminMemberDetail(id));
    return Member.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Member> createMember({
    required String username,
    required String password,
    required String namaMember,
    required String instansi,
    required String alamat,
    required String telp,
    String? foto,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.adminMembers,
      data: {
        'username': username,
        'password': password,
        'nama_member': namaMember,
        'instansi': instansi,
        'alamat': alamat,
        'telp': telp,
        if (foto != null && foto.isNotEmpty) 'foto': foto,
      },
    );
    return Member.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Member> updateMember(
    int id, {
    String? namaMember,
    String? instansi,
    String? alamat,
    String? telp,
    String? password,
    String? foto,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.adminMemberDetail(id),
      data: <String, dynamic>{
        'nama_member': ?namaMember,
        'instansi': ?instansi,
        'alamat': ?alamat,
        'telp': ?telp,
        if (password != null && password.isNotEmpty) 'password': password,
        if (foto != null && foto.isNotEmpty) 'foto': foto,
      },
    );
    return Member.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteMember(int id) async {
    await _apiClient.delete(ApiConstants.adminMemberDetail(id));
  }
}
