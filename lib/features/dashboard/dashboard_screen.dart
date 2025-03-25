import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../data_entry/data_entry_screen.dart';
import '../home/home_screen.dart';
import '../markets/markets_screen.dart';
import '../predictions/predictions_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/connectivity_banner.dart';
import 'widgets/offline_sync_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const MarketsScreen(),
    const SizedBox(), // Placeholder for FAB
    const PredictionsScreen(),
    ProfileScreen(),
  ];
  
  final List<String> _titles = [
    'Dashboard',
    'Markets',
    '',
    'Predictions',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts();
    await productProvider.fetchMarkets();
    
    if (productProvider.products.isNotEmpty) {
      await productProvider.fetchPriceData(
        productProvider.products.first.name,
        'Week',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Navigate to notifications screen
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Connectivity Banner
          if (!connectivityProvider.isConnected)
            const ConnectivityBanner(),
          
          // Offline Sync Button
          if (connectivityProvider.isConnected && productProvider.isOffline)
            const OfflineSyncButton(),
          
          // Main Content
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataEntryScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 2 ? 0 : _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DataEntryScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Predictions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

