import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    ('Explore', Icons.explore_outlined),
    ('Restaurants', Icons.restaurant_outlined),
    ('Hotels', Icons.hotel_outlined),
    ('Coffee', Icons.local_cafe_outlined),
    ('Groceries', Icons.local_grocery_store_outlined),
  ];

  final _searchController = TextEditingController();
  int _selectedCategory = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Text(
                  'Google Maps',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(height: 1),
              _drawerItem(Icons.bookmark_border, 'Saved'),
              _drawerItem(Icons.history, 'Recent'),
              _drawerItem(Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        toolbarHeight: 72,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            icon: const Icon(Icons.menu, color: Color(0xFF5F6368)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search Google Maps',
              hintStyle: const TextStyle(color: Color(0xFF5F6368)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5F6368)),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFF1A73E8),
              child: const Text(
                'A',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (label, icon) = _categories[index];
                final selected = _selectedCategory == index;
                return ChoiceChip(
                  avatar: Icon(
                    icon,
                    size: 18,
                    color: selected ? Colors.white : const Color(0xFF5F6368),
                  ),
                  label: Text(label),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedCategory = index),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF1A73E8),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF1A73E8)
                        : const Color(0xFFDADCE0),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF3C4043),
                    fontWeight: FontWeight.w500,
                  ),
                  shape: const StadiumBorder(),
                );
              },
            ),
          ),
          const Expanded(child: ColoredBox(color: Color(0xFFF2F5F7))),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5F6368)),
      title: Text(label),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
