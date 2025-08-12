import 'package:flutter/material.dart';
import 'package:shelflife/screens/setting_screen.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  String _currentEnvironment = '';
  late AuthService _authService;
  late ApiService _apiService;
  bool _showExpiringOnly = false;
  List<dynamic> _items = [];
  bool _isLoading = true;
  bool _isAdding = false;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _apiService = ApiService();
    _searchController.addListener(() {
      filterItems();
    });
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterItems() {
    final query = _searchController.text.toLowerCase();
    print('Filtering items with query: $query');
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_items);
      });
    } else {
      setState(() {
        _filteredItems =
            _items.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              return name.contains(query);
            }).toList();
      });
    }
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.get('items'); // Fetch items list
      print('Items fetched: $response');

      if (response != null &&
          response['status'] == 1 &&
          response['data'] != null) {
        final itemsList = response['data'];
        if (itemsList is List) {
          setState(() {
            _items = itemsList;
            _filteredItems = List.from(itemsList); // initialize filtered list
          });
        } else {
          print('Unexpected data format for items');
          setState(() {
            _items = [];
            _filteredItems = [];
          });
        }
      } else {
        setState(() {
          _items = [];
          _filteredItems = [];
        });
        print('Error or empty data from API');
      }
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        _items = [];
        _filteredItems = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchExpiringSoonItems() async {
  setState(() {
    _isLoading = true;
  });
  try {
    final response = await _apiService.get('items/expiring-soon');
    print('Expiring soon items fetched: $response');

    if (response != null && response['status'] == 1 && response['data'] != null) {
      final itemsList = response['data'];
      if (itemsList is List) {
        setState(() {
          _items = itemsList;
          _filteredItems = List.from(itemsList);
        });
      } else {
        print('Unexpected data format for expiring soon items');
        setState(() {
          _items = [];
          _filteredItems = [];
        });
      }
    } else {
      print('Error or empty data from expiring soon API');
      setState(() {
        _items = [];
        _filteredItems = [];
      });
    }
  } catch (e) {
    print('Error fetching expiring soon items: $e');
    setState(() {
      _items = [];
      _filteredItems = [];
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _addItem(Map<String, dynamic> newItem) async {
    setState(() {
      _isAdding = true;
    });
    try {
      final response = await _apiService.post('items', newItem);
      print('Add item response: $response');
      if (response != null) {
        // Optionally you could check success status here
        await _fetchItems(); // Refresh list after adding
      }
    } catch (e) {
      print('Error adding item: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  void _showAddItemDialog() {
    final _nameController = TextEditingController();
    final _categoryController = TextEditingController();
    final _purchaseDateController = TextEditingController();
    final _expiryDateController = TextEditingController();
    final _quantityController = TextEditingController();
    final _notesController = TextEditingController();

    DateTime? _selectedPurchaseDate;
    DateTime? _selectedExpiryDate;

    Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final formattedDate =
            "${picked.year.toString().padLeft(4, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
        if (isPurchaseDate) {
          _selectedPurchaseDate = picked;
          _purchaseDateController.text = formattedDate;
        } else {
          _selectedExpiryDate = picked;
          _expiryDateController.text = formattedDate;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: _purchaseDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date (YYYY-MM-DD)',
                      ),
                      onTap: () async {
                        await _selectDate(context, true);
                        setStateDialog(() {}); // refresh dialog UI
                      },
                    ),
                    TextField(
                      controller: _expiryDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (YYYY-MM-DD)',
                      ),
                      onTap: () async {
                        await _selectDate(context, false);
                        setStateDialog(() {});
                      },
                    ),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newItem = {
                      'name': _nameController.text.trim(),
                      'category': _categoryController.text.trim(),
                      'purchase_date': _purchaseDateController.text.trim(),
                      'expiry_date': _expiryDateController.text.trim(),
                      'quantity':
                          int.tryParse(_quantityController.text.trim()) ?? 1,
                      'notes': _notesController.text.trim(),
                    };

                    Navigator.of(context).pop(); // Close dialog
                    _addItem(newItem);
                  },
                  child:
                      _isAdding
                          ? const CircularProgressIndicator()
                          : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(item['name'] ?? 'No Name'),
        subtitle: Text(
          '${item['category'] ?? '-'} | Expiry: ${item['expiry_date'] ?? '-'}\nNotes: ${item['notes'] ?? ''}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Edit',
              onPressed: () {
                _showEditItemDialog(item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () {
                _confirmDeleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(dynamic item) {
    final _nameController = TextEditingController(text: item['name']);
    final _categoryController = TextEditingController(text: item['category']);
    final _purchaseDateController = TextEditingController(
      text: item['purchase_date'],
    );
    final _expiryDateController = TextEditingController(
      text: item['expiry_date'],
    );
    final _quantityController = TextEditingController(
      text: item['quantity'].toString(),
    );
    final _notesController = TextEditingController(text: item['notes']);

    DateTime? _selectedPurchaseDate = DateTime.tryParse(
      item['purchase_date'] ?? '',
    );
    DateTime? _selectedExpiryDate = DateTime.tryParse(
      item['expiry_date'] ?? '',
    );

    Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate:
            isPurchaseDate
                ? (_selectedPurchaseDate ?? DateTime.now())
                : (_selectedExpiryDate ?? DateTime.now()),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        final formattedDate =
            "${picked.year.toString().padLeft(4, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
        if (isPurchaseDate) {
          _selectedPurchaseDate = picked;
          _purchaseDateController.text = formattedDate;
        } else {
          _selectedExpiryDate = picked;
          _expiryDateController.text = formattedDate;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: _purchaseDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date (YYYY-MM-DD)',
                      ),
                      onTap: () async {
                        await _selectDate(context, true);
                        setStateDialog(() {});
                      },
                    ),
                    TextField(
                      controller: _expiryDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (YYYY-MM-DD)',
                      ),
                      onTap: () async {
                        await _selectDate(context, false);
                        setStateDialog(() {});
                      },
                    ),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedItem = {
                      'name': _nameController.text.trim(),
                      'category': _categoryController.text.trim(),
                      'purchase_date': _purchaseDateController.text.trim(),
                      'expiry_date': _expiryDateController.text.trim(),
                      'quantity':
                          int.tryParse(_quantityController.text.trim()) ?? 1,
                      'notes': _notesController.text.trim(),
                    };

                    Navigator.of(context).pop();
                    await _updateItem(item['id'], updatedItem);
                  },
                  child:
                      _isAdding
                          ? const CircularProgressIndicator()
                          : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteItem(dynamic item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${item['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteItem(item['id']);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(int itemId) async {
    try {
      final response = await _apiService.delete('items/$itemId');
      print('Delete item response: $response');
      await _fetchItems(); // Refresh list after deletion
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> _updateItem(int itemId, Map<String, dynamic> updatedItem) async {
    print('Updating item with ID: $itemId');
    setState(() {
      _isAdding = true;
    });
    try {
      final response = await _apiService.put('items/$itemId', updatedItem);
      print('Update item response: $response');
      if (response != null) {
        await _fetchItems(); // Refresh list after update
      }
    } catch (e) {
      print('Error updating item: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.removeToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _setting() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _setting,
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar + filter icon row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Expanded search text field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter icon button (you can add filter logic on press)
                IconButton(
                  icon: Icon(
                    _showExpiringOnly ? Icons.filter_alt : Icons.filter_list,
                  ),
                  tooltip:
                      _showExpiringOnly
                          ? 'Show All Items'
                          : 'Show Expiring Soon',
                  onPressed: () async {
                    setState(() {
                      _showExpiringOnly = !_showExpiringOnly;
                    });

                    if (_showExpiringOnly) {
                      await _fetchExpiringSoonItems();
                    } else {
                      await _fetchItems();
                    }
                  },
                ),

                // IconButton(
                //   icon: const Icon(Icons.filter_list),
                //   tooltip: 'Filters',
                //   onPressed: () {
                //     // TODO: Implement filter options dialog or screen
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Filter options coming soon!'),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredItems.isEmpty
                    ? const Center(child: Text('No items found. Add some!'))
                    : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildItemCard(item);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }
}
