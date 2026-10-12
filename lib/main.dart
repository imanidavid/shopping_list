import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class Item {
  Item(this.name);

  final String name;
  bool bought = false;
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const HomeScreen(title: 'My Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = [Item('Milk'), Item('Bread'), Item('Rice')];
  final controller = TextEditingController();

  int get itemsLeft => items.where((item) => !item.bought).length;

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }
    final alreadyThere = items.any(
      (item) => item.name.toLowerCase() == text.toLowerCase(),
    );
    if (alreadyThere) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text is already on the list')),
      );
      return;
    }
    setState(() {
      items.add(Item(text));
    });
    controller.clear();
  }

  void removeItem(int index) {
    final removed = items[index].name;
    setState(() {
      items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$removed removed')),
    );
  }

  void toggleBought(int index) {
    setState(() {
      items[index].bought = !items[index].bought;
    });
  }

  void clearBought() {
    setState(() {
      items.removeWhere((item) => item.bought);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($itemsLeft left)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Remove bought items',
            onPressed: clearBought,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Add an item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your list is empty'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Icon(
                          item.bought
                              ? Icons.check_circle
                              : Icons.shopping_basket,
                        ),
                        title: Text(
                          item.name,
                          style: item.bought
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        onTap: () => toggleBought(index),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeItem(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
