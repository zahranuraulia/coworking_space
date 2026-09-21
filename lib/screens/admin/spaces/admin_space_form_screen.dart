import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/space.dart';
import '../../../services/admin_service.dart';
import '../../../services/upload_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/stitch_app_bar.dart';

class AdminSpaceFormScreen extends StatefulWidget {
  final Space? space;

  const AdminSpaceFormScreen({super.key, this.space});

  @override
  State<AdminSpaceFormScreen> createState() => _AdminSpaceFormScreenState();
}

class _AdminSpaceFormScreenState extends State<AdminSpaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  final UploadService _uploadService = UploadService();

  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _kapasitasController;
  late final TextEditingController _deskripsiController;

  String _selectedType = 'desk';
  String? _uploadedPhoto;
  String? _localPhotoPath;
  bool _isUploadingPhoto = false;
  bool _isLoading = false;

  final List<Map<String, String>> _typeOptions = [
    {'value': 'desk', 'label': 'Personal Desk'},
    {'value': 'private_office', 'label': 'Private Office'},
    {'value': 'meeting_room', 'label': 'Meeting Room'},
  ];

  final List<String> _availableFacilities = [
    'High-Speed WiFi',
    'Stopkontak',
    'AC',
    'Smart TV',
    'Whiteboard',
    'Proyektor',
    'Free Coffee & Tea',
  ];

  final Set<String> _selectedFacilities = {};

  @override
  void initState() {
    super.initState();
    final s = widget.space;
    _namaController = TextEditingController(text: s?.namaSpace ?? '');
    _hargaController = TextEditingController(
      text: s != null ? s.hargaPerJam.toInt().toString() : '',
    );
    _kapasitasController = TextEditingController(
      text: s != null ? s.kapasitas.toString() : '1',
    );
    _deskripsiController = TextEditingController(text: s?.deskripsi ?? '');
    _selectedType = s?.tipe ?? 'desk';
    _uploadedPhoto = s?.foto;

    if (s?.deskripsi != null && s!.deskripsi!.isNotEmpty) {
      for (final f in _availableFacilities) {
        if (s.deskripsi!.toLowerCase().contains(f.toLowerCase())) {
          _selectedFacilities.add(f);
        }
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _kapasitasController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _localPhotoPath = picked.path;
      _isUploadingPhoto = true;
    });

    try {
      final filename = await _uploadService.uploadSpacePhoto(picked.path);
      if (!mounted) return;
      setState(() {
        _uploadedPhoto = filename;
        _isUploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto ruangan berhasil diunggah'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal unggah foto: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final nama = _namaController.text.trim();
    final harga = double.tryParse(_hargaController.text.trim()) ?? 0.0;
    final kapasitas = int.tryParse(_kapasitasController.text.trim()) ?? 1;

    final facilitiesText = _selectedFacilities.isNotEmpty
        ? 'Fasilitas: ${_selectedFacilities.join(', ')}. '
        : '';
    final finalDeskripsi = '$facilitiesText${_deskripsiController.text.trim()}'.trim();

    try {
      if (widget.space == null) {
        await _adminService.createSpace(
          namaSpace: nama,
          hargaPerJam: harga,
          tipe: _selectedType,
          kapasitas: kapasitas,
          deskripsi: finalDeskripsi,
          localFilePath: _localPhotoPath,
          foto: _uploadedPhoto,
        );
      } else {
        await _adminService.updateSpace(
          widget.space!.id,
          namaSpace: nama,
          hargaPerJam: harga,
          tipe: _selectedType,
          kapasitas: kapasitas,
          deskripsi: finalDeskripsi,
          localFilePath: _localPhotoPath,
          foto: _uploadedPhoto,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.space == null ? 'Space baru berhasil ditambahkan' : 'Data space berhasil diperbarui',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (widget.space == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Space Ruangan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'Data "${widget.space!.namaSpace}" akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(90, 36),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _adminService.deleteSpace(widget.space!.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Space berhasil dihapus'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.space != null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: isEdit ? 'Edit Space' : 'Tambah Space',
        subtitle: 'NexusSpace Coworking Hub',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Label (Stitch)
                const Text(
                  'Detail Ruangan / Workstation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Konfigurasikan unit kerja, fasilitas, dan tarif per jam.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // Foto Ruangan Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto Ruangan / Space',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG maksimal 5MB (Format 16:9 disarankan)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          child: _localPhotoPath != null
                              ? Image.file(
                                  File(_localPhotoPath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : (widget.space?.fotoUrl != null && widget.space!.fotoUrl!.isNotEmpty)
                                  ? Image.network(
                                      widget.space!.fotoUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.image_outlined, size: 40, color: AppColors.textMuted),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.add_photo_alternate_outlined, size: 44, color: AppColors.textMuted),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: _isUploadingPhoto ? 'Mengunggah Foto...' : 'Pilih Gambar Ruangan',
                        variant: AppButtonVariant.outline,
                        icon: Icons.camera_alt_outlined,
                        isLoading: _isUploadingPhoto,
                        onPressed: _isUploadingPhoto ? null : _pickAndUploadImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Form Fields Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Nama Space / Ruangan *',
                        hintText: 'Contoh: Personal Desk Alpha 01',
                        controller: _namaController,
                        prefixIcon: Icons.meeting_room_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama space wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),

                      // Tipe Space
                      const Text(
                        'Tipe Space *',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _typeOptions.map((opt) {
                          final isSelected = _selectedType == opt['value'];
                          return ChoiceChip(
                            label: Text(opt['label']!),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            onSelected: (sel) {
                              if (sel) setState(() => _selectedType = opt['value']!);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Kapasitas (Orang) *',
                              hintText: '1',
                              controller: _kapasitasController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.people_outline,
                              validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) <= 0
                                  ? 'Minimal 1 orang'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Tarif / Jam (Rp) *',
                              hintText: '25000',
                              controller: _hargaController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.payments_outlined,
                              validator: (v) => (double.tryParse(v?.trim() ?? '') ?? 0.0) <= 0
                                  ? 'Tarif tidak valid'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fasilitas Tersedia
                      const Text(
                        'Fasilitas Tersedia',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableFacilities.map((fac) {
                          final isChecked = _selectedFacilities.contains(fac);
                          return FilterChip(
                            label: Text(fac),
                            selected: isChecked,
                            selectedColor: const Color(0xFFEFF6FF),
                            checkmarkColor: AppColors.accentBlue,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isChecked ? AppColors.accentBlue : AppColors.textSecondary,
                              fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isChecked ? AppColors.accentBlue : AppColors.border,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFacilities.add(fac);
                                } else {
                                  _selectedFacilities.remove(fac);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Deskripsi Tambahan Ruangan',
                        hintText: 'Tuliskan rincian fasilitas dan spesifikasi...',
                        controller: _deskripsiController,
                        maxLines: 3,
                        prefixIcon: Icons.notes_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: isEdit ? 'SIMPAN PERUBAHAN SPACE' : 'SIMPAN DATA SPACE',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSave,
                ),

                if (isEdit) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Hapus Space Ini',
                    variant: AppButtonVariant.danger,
                    icon: Icons.delete_outline,
                    onPressed: _isLoading ? null : _handleDelete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
