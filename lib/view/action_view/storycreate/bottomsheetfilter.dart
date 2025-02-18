// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class BottomSheetContent extends StatelessWidget {
  const BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(
                    icon: Icon(Icons.filter, color: Colors.purple),
                    text: 'Filter'),
                Tab(
                    icon: Icon(Icons.content_cut, color: Colors.purple),
                    text: 'Trim'),
              ],
              indicatorColor: Colors.purple,
              labelColor: Colors.purple,
            ),
            SizedBox(
              height: 100, // Set a fixed height for the TabBarView
              child: TabBarView(
                children: [
                  const FilterTabContent(),
                  TrimTabContent(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle save changes action
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class FilterTabContent extends StatelessWidget {
  const FilterTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FilterOption(label: 'E1', image: 'assets/images/black.jpg'),
        FilterOption(label: 'E4', image: 'assets/images/bl.jpg'),
        FilterOption(label: 'E3', image: 'assets/images/antique.jpg'),
      ],
    );
  }
}

class TrimTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Trim options will be here'),
    );
  }
}

class IconWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconWithLabel({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.purple),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.purple)),
      ],
    );
  }
}

class FilterOption extends StatelessWidget {
  final String label;
  final String image;

  const FilterOption({
    super.key,
    required this.label,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(image, width: 60, height: 60),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.purple)),
      ],
    );
  }
}
