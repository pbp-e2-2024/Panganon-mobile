import 'package:flutter/material.dart';
import '../../models/restaurant.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;
  
  // dummy restaurant images
  static const List<String> dummyImages = [
    'https://as1.ftcdn.net/v2/jpg/02/06/04/70/1000_F_206047084_OxZGQ404N8rocQmItLIQRMRWlQwV3mSH.jpg',
    'https://as2.ftcdn.net/v2/jpg/08/55/94/91/1000_F_855949179_9jellTgfwfhAk1uMAdsiL37x8G48rYvs.jpg',
    'https://as2.ftcdn.net/v2/jpg/09/37/80/73/1000_F_937807344_fmOII9oJX3klVXUJWV4JZ1Ic6A1njeRm.jpg',
    'https://as2.ftcdn.net/v2/jpg/08/79/39/83/1000_F_879398358_4xEEG9Eu6REmOySYboiVG4u1vvDF9fju.jpg',
    'https://as1.ftcdn.net/v2/jpg/08/51/15/28/1000_F_851152836_QLIuFpyQ94mqd2abpnpIXJNzlZH2PIU7.jpg',
  ];

  const RestaurantDetailPage({super.key, required this.restaurant});

  String getRestaurantImage() {
    // Use restaurant's ID or name to select an image
    // This ensures the same restaurant always gets the same image
    final index = restaurant.name.length % dummyImages.length;
    return dummyImages[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black.withOpacity(0.7),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    getRestaurantImage(),
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  // Scroll indicator
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 32,
                        ),
                        const Text(
                          'Scroll down',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // ...existing content...
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 20, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant.address,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        if (restaurant.priceRange != null) ...[
                          _buildSectionTitle(context, 'Price Range'),
                          Text(
                            restaurant.priceRange!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                        ],
                        _buildSectionTitle(context, 'Services'),
                        Wrap(
                          spacing: 8,
                          children: restaurant.services.map((service) => Chip(
                            label: Text(service),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(color: Colors.black),
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, 'Opening Hours'),
                        ...restaurant.openingHours.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(e.value),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}