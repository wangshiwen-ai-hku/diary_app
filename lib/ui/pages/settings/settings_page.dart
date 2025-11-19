import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/theme_provider.dart';
import '../../theme/theme_colors.dart';

// User Info Providers
final userNameProvider = StateProvider<String>((ref) => '');
final partnerNameProvider = StateProvider<String>((ref) => '');
final anniversaryDateProvider = StateProvider<DateTime?>((ref) => null);

// AI Settings Providers
final defaultStyleProvider = StateProvider<String>((ref) => 'warm');
final aiModelProvider = StateProvider<String>((ref) => 'GPT-4');

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _userNameController;
  late TextEditingController _partnerNameController;
  bool _cloudSyncEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _partnerNameController = TextEditingController();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _userNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Profile
    final userName = prefs.getString('user_name') ?? '';
    final partnerName = prefs.getString('partner_name') ?? '';
    final anniversaryTimestamp = prefs.getInt('anniversary_date');
    
    // Load AI Settings
    final defaultStyle = prefs.getString('default_style') ?? 'warm';
    final aiModel = prefs.getString('ai_model') ?? 'GPT-4';
    
    // Load Data Settings
    final cloudSync = prefs.getBool('cloud_sync') ?? false;
    
    setState(() {
      _userNameController.text = userName;
      _partnerNameController.text = partnerName;
      _cloudSyncEnabled = cloudSync;
      
      ref.read(userNameProvider.notifier).state = userName;
      ref.read(partnerNameProvider.notifier).state = partnerName;
      if (anniversaryTimestamp != null) {
        ref.read(anniversaryDateProvider.notifier).state = 
            DateTime.fromMillisecondsSinceEpoch(anniversaryTimestamp);
      }
      ref.read(defaultStyleProvider.notifier).state = defaultStyle;
      ref.read(aiModelProvider.notifier).state = aiModel;
    });
  }
  
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userNameController.text);
    await prefs.setString('partner_name', _partnerNameController.text);
    
    ref.read(userNameProvider.notifier).state = _userNameController.text;
    ref.read(partnerNameProvider.notifier).state = _partnerNameController.text;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }
  
  Future<void> _selectAnniversaryDate() async {
    final currentDate = ref.read(anniversaryDateProvider) ?? DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('anniversary_date', date.millisecondsSinceEpoch);
      ref.read(anniversaryDateProvider.notifier).state = date;
    }
  }

  Future<void> _updateAIModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_model', model);
    ref.read(aiModelProvider.notifier).state = model;
  }

  Future<void> _updateDefaultStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_style', style);
    ref.read(defaultStyleProvider.notifier).state = style;
  }

  Future<void> _toggleCloudSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_sync', value);
    setState(() {
      _cloudSyncEnabled = value;
    });
    
    if (value) {
      // Mock sync start
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syncing with cloud...')),
      );
    }
  }

  Future<void> _exportData() async {
    // Mock export - share a summary string
    final userName = ref.read(userNameProvider);
    final partnerName = ref.read(partnerNameProvider);
    final anniversary = ref.read(anniversaryDateProvider);
    
    final content = '''
Our Universe Data Export
User: $userName
Partner: $partnerName
Anniversary: ${anniversary != null ? DateFormat('yyyy-MM-dd').format(anniversary) : 'Not set'}
Exported: ${DateTime.now()}
''';
    
    await Share.share(content, subject: 'Our Universe Data Export');
  }

  Future<void> _backupData() async {
    // Mock backup
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local backup created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Deep black background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            title: 'Profile',
            children: [
              _buildTextField(
                label: 'My Name',
                controller: _userNameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Partner\'s Name',
                controller: _partnerNameController,
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 16),
              _buildDateTile(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Profile',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSection(
            title: 'AI Configuration',
            children: [
              _buildDropdown(
                label: 'Default Style',
                value: ref.watch(defaultStyleProvider),
                items: ['Warm', 'Poetic', 'Funny', 'Realistic'],
                onChanged: (val) => _updateDefaultStyle(val!),
                icon: Icons.auto_awesome,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'AI Model',
                value: ref.watch(aiModelProvider),
                items: ['GPT-4', 'Claude 3.5', 'Gemini Pro'],
                onChanged: (val) => _updateAIModel(val!),
                icon: Icons.psychology,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSection(
            title: 'Data Management',
            children: [
              _buildSwitchTile(
                title: 'Cloud Sync',
                subtitle: 'Auto sync to secure cloud',
                value: _cloudSyncEnabled,
                onChanged: _toggleCloudSync,
                icon: Icons.cloud_sync_outlined,
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                title: 'Export Data',
                subtitle: 'Export as text/markdown',
                icon: Icons.ios_share,
                onTap: _exportData,
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                title: 'Backup & Restore',
                subtitle: 'Create local backup',
                icon: Icons.save_alt,
                onTap: _backupData,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSection(
            title: 'About',
            children: [
              _buildActionTile(
                title: 'About Us',
                subtitle: 'Version 1.0.0',
                icon: Icons.info_outline,
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Our Universe',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.favorite, size: 40, color: Colors.pink),
                  children: [
                    const Text('Record your beautiful moments with AI.'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          Center(
            child: TextButton(
              onPressed: () {
                // Mock logout
                Navigator.pop(context);
              },
              child: Text(
                'Log Out',
                style: GoogleFonts.lato(
                  color: Colors.red.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.lato(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDateTile() {
    final date = ref.watch(anniversaryDateProvider);
    return InkWell(
      onTap: _selectAnniversaryDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white60, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anniversary',
                    style: GoogleFonts.lato(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Set Date',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            dropdownColor: const Color(0xFF2A2A2A),
            style: GoogleFonts.lato(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.lato(color: Colors.white60),
              border: InputBorder.none,
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.white24,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white60, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
