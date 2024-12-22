import 'package:flutter/material.dart';
import 'package:panganon_mobile/screens/about_me/aboutme_page.dart';
import 'package:panganon_mobile/screens/daftar_makanan/daftar_makanan.dart';
import 'package:panganon_mobile/screens/event/event_list.dart';
import 'package:panganon_mobile/screens/favorites/favorites_page.dart';
import 'package:panganon_mobile/widgets/leftdrawer.dart';
import 'package:panganon_mobile/screens/forum/home_forum.dart';

class MenuPage extends StatefulWidget {
  final String username;
  final String profileImageUrl;

  const MenuPage({
    super.key,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<ItemHomepage> items = [
    ItemHomepage("About Me", Icons.info),
    ItemHomepage("Daftar Makanan", Icons.fastfood),
    ItemHomepage("Forum", Icons.forum),
    ItemHomepage("Favorite", Icons.favorite),
    ItemHomepage("Event", Icons.event),
  ];

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      drawer: LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Welcome to Panganon!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: ItemCard(
                        items[0],
                        onClick: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AboutMePage()),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ItemCard(
                      items[1],
                      onClick: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DaftarMakananPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ItemCard(
                      items[2],
                      onClick: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForumPage(
                            username: widget.username,
                            profileImageUrl: widget.profileImageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ItemCard(
                      items[3],
                      onClick: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteRestaurantsScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ItemCard(
                      items[4],
                      onClick: () =>
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventListPage(),
                        ),
                      ),
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
}

class ItemHomepage {
  final String title;
  final IconData icon;

  ItemHomepage(this.title, this.icon);
}

class ItemCard extends StatefulWidget {
  final ItemHomepage item;
  final VoidCallback? onClick;

  const ItemCard(this.item, {this.onClick, super.key});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      child: Card(
        elevation: isHovered ? 8.0 : 2.0,
        color: isHovered ? Colors.blue[50] : Colors.white,
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.item.icon, size: 32, color: Colors.black),
              const SizedBox(height: 8.0),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}