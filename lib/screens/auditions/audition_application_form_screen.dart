import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../models/audition_model.dart';
import '../../services/audition_service.dart';

class AuditionApplicationFormScreen extends StatefulWidget {
  final AuditionCall? auditionCall;
  final VoidCallback onSubmitted;

  const AuditionApplicationFormScreen({
    super.key,
    this.auditionCall,
    required this.onSubmitted,
  });

  @override
  State<AuditionApplicationFormScreen> createState() => _AuditionApplicationFormScreenState();
}

class _AuditionApplicationFormScreenState extends State<AuditionApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String _selectedRole = 'actor';
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController(text: 'Male');
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _heightController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');
  final _targetRoleController = TextEditingController();
  final _bioController = TextEditingController();
  final _pastWorkController = TextEditingController();

  // Writer specific
  final _scriptTitleController = TextEditingController();
  final _scriptLoglineController = TextEditingController();

  // Links
  final _showreelController = TextEditingController();
  final _portfolioController = TextEditingController();

  // Media files
  File? _monologueVideoFile;
  final List<File> _headshotFiles = [];
  File? _scriptSampleFile;

  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _roles = [
    {'id': 'actor', 'label': 'Actor / Actress', 'icon': '🎭', 'desc': 'Lead & Character Roles'},
    {'id': 'writer', 'label': 'Scriptwriter', 'icon': '✍️', 'desc': 'Screenplay & Dialogue'},
    {'id': 'director', 'label': 'Director / AD', 'icon': '🎬', 'desc': 'Direction & Filmmaking'},
    {'id': 'singer', 'label': 'Singer / Music', 'icon': '🎵', 'desc': 'Vocals & Score'},
    {'id': 'cinematographer', 'label': 'Cinematographer', 'icon': '🎥', 'desc': 'Camera & DOP'},
    {'id': 'editor', 'label': 'Editor / VFX', 'icon': '🎞️', 'desc': 'Post-Production'},
    {'id': 'other', 'label': 'Other Talent', 'icon': '⭐', 'desc': 'Crew & Stunts'},
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.userName != null) _fullNameController.text = appState.userName!;
    if (appState.phoneNumber != null) {
      _phoneController.text = appState.phoneNumber!;
      _whatsappController.text = appState.phoneNumber!;
    }
    if (appState.userAge != null) _ageController.text = appState.userAge.toString();
    if (appState.userGender != null) _genderController.text = appState.userGender!;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _heightController.dispose();
    _experienceController.dispose();
    _targetRoleController.dispose();
    _bioController.dispose();
    _pastWorkController.dispose();
    _scriptTitleController.dispose();
    _scriptLoglineController.dispose();
    _showreelController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _pickHeadshot() async {
    if (_headshotFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 photos allowed.')),
      );
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _headshotFiles.add(File(picked.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 3),
    );
    if (picked != null) {
      setState(() {
        _monologueVideoFile = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.authToken;

    if (token == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Please log in to submit your audition.';
      });
      return;
    }

    final fields = <String, String>{
      'role_category': _selectedRole,
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'email': _emailController.text.trim(),
      if (_ageController.text.isNotEmpty) 'age': _ageController.text.trim(),
      'gender': _genderController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'height': _heightController.text.trim(),
      'experience_years': _experienceController.text.trim(),
      'target_role': _targetRoleController.text.trim(),
      'bio': _bioController.text.trim(),
      'past_work': _pastWorkController.text.trim(),
      'script_title': _scriptTitleController.text.trim(),
      'script_logline': _scriptLoglineController.text.trim(),
      'showreel_link': _showreelController.text.trim(),
      'portfolio_url': _portfolioController.text.trim(),
      if (widget.auditionCall != null) 'audition_id': widget.auditionCall!.id.toString(),
      'amount_paid': (widget.auditionCall?.registrationFee ?? 199.0).toString(),
    };

    try {
      await AuditionService.submitAudition(
        token,
        fields,
        monologueVideo: _monologueVideoFile,
        scriptSample: _scriptSampleFile,
        headshots: _headshotFiles,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('🎉 Audition Application Submitted Successfully!'),
          ),
        );
        widget.onSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Audition Registration Form',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Casting Call Summary Card (if from specific listing)
              if (widget.auditionCall != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_filter, color: Color(0xFFE50914), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'APPLYING FOR',
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.auditionCall!.title,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // STEP 1: Role Selection
              _buildSectionTitle('1. Select Your Talent Category'),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedRole == role['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRole = role['id']),
                      child: Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE50914) : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE50914) : Colors.white12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(role['icon'], style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(
                              role['label'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              role['desc'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: isSelected ? Colors.white70 : Colors.white38,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // STEP 2: Personal Details
              _buildSectionTitle('2. Candidate Information'),
              const SizedBox(height: 12),
              _buildTextField(_fullNameController, 'Full Name *', Icons.person, isRequired: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_phoneController, 'Mobile Phone *', Icons.phone, isRequired: true, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_whatsappController, 'WhatsApp No.', Icons.chat, keyboardType: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_ageController, 'Age (Years)', Icons.calendar_today, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _genderController.text.isNotEmpty ? _genderController.text : 'Male',
                          dropdownColor: const Color(0xFF2C2C2E),
                          isExpanded: true,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _genderController.text = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_stateController, 'State', Icons.map)),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedRole == 'actor') ...[
                Row(
                  children: [
                    Expanded(child: _buildTextField(_heightController, "Height (e.g. 5'10\")", Icons.height)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_experienceController, 'Exp. (Years)', Icons.work_history, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              _buildTextField(_targetRoleController, 'Specific Role (e.g. Lead Antagonist / Lead Actress)', Icons.badge),
              const SizedBox(height: 12),
              _buildTextField(_bioController, 'Introduction / Bio (Why work with NetLiv?)', Icons.description, maxLines: 3),
              const SizedBox(height: 24),

              // STEP 3: Role Specific Media & Portfolio
              if (_selectedRole == 'actor') ...[
                _buildSectionTitle('3. Photos & Monologue Video'),
                const SizedBox(height: 12),

                // Photos Picker
                Text('Portfolio / Headshot Photos (Up to 3):', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ..._headshotFiles.map((file) => Stack(
                          children: [
                            Container(
                              width: 75,
                              height: 95,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => setState(() => _headshotFiles.remove(file)),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )),
                    if (_headshotFiles.length < 3)
                      GestureDetector(
                        onTap: _pickHeadshot,
                        child: Container(
                          width: 75,
                          height: 95,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white70, size: 22),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Video Picker
                Text('Acting Monologue Clip (Max 2 mins):', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _monologueVideoFile != null ? const Color(0xFF46D369) : Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _monologueVideoFile != null ? Icons.check_circle : Icons.videocam,
                          color: _monologueVideoFile != null ? const Color(0xFF46D369) : Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _monologueVideoFile != null ? 'Video Selected (${_monologueVideoFile!.path.split('/').last})' : 'Tap to select Monologue Video clip from Gallery',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_selectedRole == 'writer') ...[
                _buildSectionTitle('3. Script & Story Synopsis'),
                const SizedBox(height: 12),
                _buildTextField(_scriptTitleController, 'Script Title / Concept Name *', Icons.menu_book, isRequired: true),
                const SizedBox(height: 12),
                _buildTextField(_scriptLoglineController, 'Story Logline / Concept Synopsis (2-3 lines) *', Icons.short_text, maxLines: 3, isRequired: true),
              ] else ...[
                _buildSectionTitle('3. Showreel & Work Links'),
                const SizedBox(height: 12),
                _buildTextField(_showreelController, 'Showreel Video / YouTube / Vimeo Link', Icons.video_library),
                const SizedBox(height: 12),
                _buildTextField(_portfolioController, 'Portfolio / IMDb / Drive Folder Link', Icons.link),
              ],
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Uploading Audition & Media...'),
                          ],
                        )
                      : Text(
                          'Submit Audition Application 🚀',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
        ),
      ),
    );
  }
}
