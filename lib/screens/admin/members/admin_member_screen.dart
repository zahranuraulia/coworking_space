import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/member.dart';
import '../../../services/member_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/stitch_app_bar.dart';

class AdminMemberScreen extends StatefulWidget {
  const AdminMemberScreen({super.key});

  @override
  State<AdminMemberScreen> createState() => _AdminMemberScreenState();
}

class _AdminMemberScreenState extends State<AdminMemberScreen> {
  final MemberService _memberService = MemberService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _memberService.getMembers(search: _searchController.text.trim());
      if (!mounted) return;
      setState(() {
        _members = list;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showMemberFormDialog({Member? member}) async {
    final isEdit = member != null;
    final formKey = GlobalKey<FormState>();

    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final namaCtrl = TextEditingController(text: member?.namaMember ?? '');
    final instansiCtrl = TextEditingController(text: member?.instansi ?? '');
    final alamatCtrl = TextEditingController(text: member?.alamat ?? '');
    final telpCtrl = TextEditingController(text: member?.telp ?? '');
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Data Member' : 'Tambah Member Baru',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      if (!isEdit) ...[
                        AppTextField(
                          label: 'Username *',
                          hintText: 'Username unik login',
                          controller: usernameCtrl,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Username wajib diisi' : null,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          label: 'Password *',
                          hintText: 'Minimal 6 karakter',
                          controller: passwordCtrl,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => (v == null || v.trim().length < 6)
                              ? 'Password minimal 6 karakter'
                              : null,
                        ),
                        const SizedBox(height: 10),
                      ],

                      AppTextField(
                        label: 'Nama Lengkap *',
                        hintText: 'Nama lengkap member',
                        controller: namaCtrl,
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),

                      AppTextField(
                        label: 'Instansi / Kampus *',
                        hintText: 'Contoh: SMK Telkom / PT Maju',
                        controller: instansiCtrl,
                        prefixIcon: Icons.business_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Instansi wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),

                      AppTextField(
                        label: 'Nomor Telepon / WA *',
                        hintText: 'Contoh: 081234567890',
                        controller: telpCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        prefixIcon: Icons.phone_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nomor kontak wajib diisi';
                          if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) {
                            return 'Nomor kontak hanya boleh berisi angka';
                          }
                          if (v.trim().length < 10) return 'Nomor kontak minimal 10 digit';
                          if (v.trim().length > 15) return 'Nomor kontak maksimal 15 digit';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      AppTextField(
                        label: 'Alamat Lengkap *',
                        hintText: 'Alamat domisili',
                        controller: alamatCtrl,
                        prefixIcon: Icons.home_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
                      ),
                      if (isEdit) ...[
                        const SizedBox(height: 10),
                        AppTextField(
                          label: 'Reset Password (Opsional)',
                          hintText: 'Kosongkan jika tidak diubah',
                          controller: passwordCtrl,
                          isPassword: true,
                          prefixIcon: Icons.lock_reset_outlined,
                        ),
                      ],
                      const SizedBox(height: 16),

                      AppButton(
                        text: isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH MEMBER',
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSaving = true);

                                try {
                                  if (!isEdit) {
                                    await _memberService.createMember(
                                      username: usernameCtrl.text.trim(),
                                      password: passwordCtrl.text.trim(),
                                      namaMember: namaCtrl.text.trim(),
                                      instansi: instansiCtrl.text.trim(),
                                      alamat: alamatCtrl.text.trim(),
                                      telp: telpCtrl.text.trim(),
                                    );
                                  } else {
                                    await _memberService.updateMember(
                                      member.id,
                                      namaMember: namaCtrl.text.trim(),
                                      instansi: instansiCtrl.text.trim(),
                                      alamat: alamatCtrl.text.trim(),
                                      telp: telpCtrl.text.trim(),
                                      password: passwordCtrl.text.trim().isNotEmpty
                                          ? passwordCtrl.text.trim()
                                          : null,
                                    );
                                  }

                                  if (!modalCtx.mounted) return;
                                  Navigator.pop(modalCtx);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !isEdit ? 'Member baru berhasil didaftarkan' : 'Data member diperbarui',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  _fetchMembers();
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menyimpan member: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDelete(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Member?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text(
          'Hapus data member "${member.namaMember}"? Riwayat transaksi pengguna ini tidak dapat dipulihkan.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _memberService.deleteMember(member.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _fetchMembers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Data Member',
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.blue200, width: 0.8),
              ),
              child: Text(
                'Total: ${_members.length} Member',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMembers,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Add Button Row (Stitch Exact Layout)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    // Search Input
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _fetchMembers(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Cari member...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchMembers();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Black Add Button (+) (Stitch Design)
                    InkWell(
                      onTap: () => _showMemberFormDialog(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A0F172A),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Member List
              Expanded(
                child: _isLoading
                    ? const LoadingWidget(message: 'Memuat data member...')
                    : _errorMessage != null
                        ? EmptyStateWidget(
                            icon: Icons.error_outline,
                            title: 'Gagal Memuat Member',
                            message: _errorMessage!,
                            actionLabel: 'Coba Lagi',
                            onAction: _fetchMembers,
                          )
                        : _members.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.people_outline,
                                title: 'Member Tidak Ditemukan',
                                message: 'Belum ada member yang sesuai dengan pencarian.',
                                actionLabel: 'Tambah Member Baru',
                                onAction: () => _showMemberFormDialog(),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: _members.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final m = _members[index];
                                  return _buildMemberCard(m);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar (Stitch soft gray circle with image support)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: ClipOval(
              child: member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                  ? Image.network(
                      member.fotoUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Member Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.namaMember,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Active Green Dot Indicator (Stitch Exact)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                if (member.instansi != null && member.instansi!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.instansi!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (member.telp != null && member.telp!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    member.telp!,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate700, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons (Stitch Small Rounded Buttons)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _showMemberFormDialog(member: member),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _handleDelete(member),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.rose50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, size: 16, color: AppColors.rose600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
