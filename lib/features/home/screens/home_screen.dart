import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../features/chat/screens/messages_list_screen.dart';
import '../../../features/discovery/screens/partner_finder_screen.dart';
import '../../../features/ideas/screens/idea_feed_screen.dart';
import '../../../features/profile/screens/my_profile_screen.dart';
import '../../../features/requests/screens/requests_list_screen.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = <Widget>[
    const PartnerFinderScreen(showAppBar: false),
    const IdeaFeedScreen(showAppBar: false),
    const RequestsListScreen(showAppBar: false),
    const MessagesListScreen(showAppBar: false),
    const MyProfileScreen(),
  ];

  static const List<String> _titles = <String>[
    'Discover \u{1F50D}',
    'Ideas \u{1F4A1}',
    'Requests \u{1F91D}',
    'Messages \u{1F4AC}',
    'My Profile \u{1F464}',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: _titles[_currentIndex],
        automaticallyImplyLeading: false,
        actions: _buildActions(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: <BottomNavigationBarItem>[
          _navItem(
            index: 0,
            label: 'Discover',
            selectedIcon: Icons.explore,
            unselectedIcon: Icons.explore_outlined,
          ),
          _navItem(
            index: 1,
            label: 'Ideas',
            selectedIcon: Icons.lightbulb,
            unselectedIcon: Icons.lightbulb_outline,
          ),
          _navItem(
            index: 2,
            label: 'Requests',
            selectedIcon: Icons.handshake_outlined,
            unselectedIcon: Icons.handshake_outlined,
            badgeCount: 2,
          ),
          _navItem(
            index: 3,
            label: 'Chat',
            selectedIcon: Icons.chat_bubble,
            unselectedIcon: Icons.chat_bubble_outline,
          ),
          _navItem(
            index: 4,
            label: 'Profile',
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required int index,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    int? badgeCount,
  }) {
    final bool isActive = _currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: _NavIcon(
        icon: isActive ? selectedIcon : unselectedIcon,
        isActive: isActive,
        badgeCount: badgeCount,
      ),
      activeIcon: _NavIcon(
        icon: selectedIcon,
        isActive: true,
        badgeCount: badgeCount,
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (_currentIndex == 1) {
      return <Widget>[
        IconButton(
          onPressed: () => context.push('/post-idea'),
          icon: const Icon(Icons.add_rounded),
        ),
      ];
    }
    return null;
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    this.badgeCount,
  });

  final IconData icon;
  final bool isActive;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isActive ? AppColors.primary : const Color(0xFF94A3B8);

    return SizedBox(
      width: 44,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          if (isActive)
            Positioned(
              top: 0,
              child: Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Positioned(
            top: 8,
            child: Icon(icon, color: iconColor),
          ),
          if (badgeCount != null)
            Positioned(
              top: 4,
              right: 0,
              child: Container(
                height: 16,
                constraints: const BoxConstraints(minWidth: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
