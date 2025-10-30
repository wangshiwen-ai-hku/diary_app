import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/theme_provider.dart';
import '../../theme/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';

// 用户信息 Provider
final userNameProvider = StateProvider<String>((ref) => '');
final partnerNameProvider = StateProvider<String>((ref) => '');
final anniversaryDateProvider = StateProvider<DateTime?>((ref) => null);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _userNameController;
  late TextEditingController _partnerNameController;
  
  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _partnerNameController = TextEditingController();
    _loadUserInfo();
  }
  
  @override
  void dispose() {
    _userNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? '';
    final partnerName = prefs.getString('partner_name') ?? '';
    final anniversaryTimestamp = prefs.getInt('anniversary_date');
    
    setState(() {
      _userNameController.text = userName;
      _partnerNameController.text = partnerName;
      ref.read(userNameProvider.notifier).state = userName;
      ref.read(partnerNameProvider.notifier).state = partnerName;
      if (anniversaryTimestamp != null) {
        ref.read(anniversaryDateProvider.notifier).state = 
            DateTime.fromMillisecondsSinceEpoch(anniversaryTimestamp);
      }
    });
  }
  
  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userNameController.text);
    await prefs.setString('partner_name', _partnerNameController.text);
    
    ref.read(userNameProvider.notifier).state = _userNameController.text;
    ref.read(partnerNameProvider.notifier).state = _partnerNameController.text;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存成功'),
          duration: const Duration(seconds: 2),
        ),
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
    );
    
    if (date != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('anniversary_date', date.millisecondsSinceEpoch);
      ref.read(anniversaryDateProvider.notifier).state = date;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('纪念日已设置'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNameProvider);
    final brightness = ref.watch(brightnessProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '亮度模式',
            children: [
              _buildBrightnessToggle(context, ref, brightness),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: '外观主题',
            children: [
              _buildThemeCard(context, ref, 'dark_mode', 'Dark Mode', currentTheme),
              _buildThemeCard(context, ref, 'light_mode', 'Light Mode', currentTheme),
              _buildThemeCard(context, ref, 'warm_beige', 'Warm Beige', currentTheme),
              _buildThemeCard(context, ref, 'soft_blue', 'Soft Blue', currentTheme),
              _buildThemeCard(context, ref, 'sage_green', 'Sage Green', currentTheme),
            ],
          ),
          
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '情侣信息',
            children: [
              _buildEditableListTile(
                context,
                icon: Icons.person_outline,
                title: '我的昵称',
                controller: _userNameController,
                hint: '请输入你的昵称',
              ),
              _buildEditableListTile(
                context,
                icon: Icons.favorite_border,
                title: 'TA的昵称',
                controller: _partnerNameController,
                hint: '请输入TA的昵称',
              ),
              _buildDateListTile(
                context,
                ref,
                icon: Icons.calendar_today_outlined,
                title: '在一起的日子',
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _saveUserInfo,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('保存信息'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: 'AI设置',
            children: [
              _buildListTile(
                icon: Icons.auto_awesome,
                title: '默认生成风格',
                subtitle: '温馨',
                onTap: () {
                  // TODO: 选择默认风格
                },
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'AI模型配置',
                subtitle: '当前使用：GPT-4',
                onTap: () {
                  // TODO: 切换AI模型
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: '数据管理',
            children: [
              _buildListTile(
                icon: Icons.cloud_upload,
                title: '云端同步',
                subtitle: '自动同步日记到云端',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: 切换云端同步
                  },
                ),
                onTap: null,
              ),
              _buildListTile(
                icon: Icons.download,
                title: '导出日记',
                subtitle: '导出为PDF或Markdown',
                onTap: () {
                  // TODO: 导出功能
                },
              ),
              _buildListTile(
                icon: Icons.backup,
                title: '备份与恢复',
                subtitle: '本地备份管理',
                onTap: () {
                  // TODO: 备份功能
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: '外观',
            children: [
              _buildListTile(
                icon: Icons.font_download,
                title: '字体设置',
                subtitle: '选择你喜欢的字体',
                onTap: () {
                  // TODO: 字体设置
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            context,
            title: '其他',
            children: [
              _buildListTile(
                icon: Icons.help_outline,
                title: '帮助与反馈',
                onTap: () {
                  // TODO: 帮助页面
                },
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: '关于我们',
                subtitle: '版本 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 退出登录按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                // TODO: 退出登录
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '我们的日记',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.favorite, size: 48, color: Colors.pink),
      children: [
        const Text('用AI记录你们的美好时光'),
        const SizedBox(height: 8),
        const Text('让每一个瞬间都值得珍藏'),
      ],
    );
  }

  Widget _buildEditableListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateListTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final anniversaryDate = ref.watch(anniversaryDateProvider);
    
    String subtitle = '点击设置纪念日';
    if (anniversaryDate != null) {
      final now = DateTime.now();
      final difference = now.difference(anniversaryDate).inDays;
      subtitle = '已在一起 $difference 天';
    }
    
    return InkWell(
      onTap: _selectAnniversaryDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessToggle(
    BuildContext context,
    WidgetRef ref,
    Brightness brightness,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            brightness == Brightness.dark 
                ? Icons.dark_mode_outlined 
                : Icons.light_mode_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brightness == Brightness.dark ? '暗色模式' : '亮色模式',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '切换全局亮度',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: brightness == Brightness.dark,
            onChanged: (isDark) {
              ref.read(brightnessProvider.notifier).state = 
                  isDark ? Brightness.dark : Brightness.light;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    String themeValue,
    String themeName,
    String currentTheme,
  ) {
    final themeColors = SystemThemeColors.getThemeColors(themeValue);
    final isSelected = currentTheme == themeValue;
    
    return InkWell(
      onTap: () {
        ref.read(themeNameProvider.notifier).state = themeValue;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? themeColors.primary
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected 
              ? themeColors.primary.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Color preview
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeColors.primary,
                    themeColors.light,
                    themeColors.medium,
                    themeColors.dark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Theme info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _ColorDot(color: themeColors.primary),
                      _ColorDot(color: themeColors.light),
                      _ColorDot(color: themeColors.medium),
                      _ColorDot(color: themeColors.dark),
                    ],
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: themeColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  
  const _ColorDot({required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }
}
