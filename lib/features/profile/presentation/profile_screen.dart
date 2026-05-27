import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/core/theme/theme_provider.dart';
import 'package:cargo_mobile/features/auth/domain/auth_provider.dart';
import 'package:cargo_mobile/shared/widgets/app_menu_group.dart';
import 'package:cargo_mobile/shared/widgets/logout_sheet.dart';
import 'package:cargo_mobile/shared/widgets/nav_button.dart';
import 'package:cargo_mobile/shared/widgets/user_hero_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.bgGradient,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NavButton(
                        onTap: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        child: Icon(
                          isDark
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_outlined,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: UserHeroCard(
                    name: 'Азат',
                    code: 'BF-2847',
                    branch: 'Бишкек — Главный',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: [
                      const AppMenuGroup(
                        items: [
                          AppMenuItem(
                            icon: Icons.phone_outlined,
                            color: Color(0xFF25D366),
                            label: 'Контактные данные',
                          ),
                          AppMenuItem(
                            icon: Icons.newspaper_outlined,
                            color: Color(0xFFFF6B35),
                            label: 'Новости',
                          ),
                          AppMenuItem(
                            icon: Icons.description_outlined,
                            color: Color(0xFF4F46E5),
                            label: 'Условия компании',
                          ),
                          AppMenuItem(
                            icon: Icons.help_outline_rounded,
                            color: Color(0xFF2AABEE),
                            label: 'Часто задаваемые вопросы',
                          ),
                          AppMenuItem(
                            icon: Icons.support_agent_outlined,
                            color: Color(0xFF268A53),
                            label: 'Помощь',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const AppMenuGroup(
                        items: [
                          AppMenuItem(
                            icon: Icons.lock_outline_rounded,
                            color: Color(0xFF8B5CF6),
                            label: 'Сменить пароль',
                          ),
                          AppMenuItem(
                            icon: Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            label: 'Удалить аккаунт',
                            danger: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppMenuGroup(
                        items: [
                          AppMenuItem(
                            icon: Icons.logout_rounded,
                            color: Color(0xFFEF4444),
                            label: 'Выйти с аккаунта',
                            danger: true,
                            onTap: () => LogoutSheet.show(
                              context,
                              onConfirm: () => ref.read(authProvider.notifier).logout(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
