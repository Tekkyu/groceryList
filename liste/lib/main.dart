import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Run the application
void main() {
  runApp(MyApp());
}

const String apiKey = 'APIKEYtest';
const String apiBaseUrl = 'http://localhost:3000';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste de course',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> groceryItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // APP bar module
        title: const Text('Liste de course'),
        actions: <Widget>[
          ElevatedButton(
            // DELETE ALL button widget with the function called
            onPressed: () {
              _showDeleteAllConfirmationDialog(context);
            },
            child: const Text('Tout supprimer'),
          ),
          IconButton(
            // Icon to refresh the data
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Call the getData function to refresh the data
              setState(() {
                // Call getData function to refresh the data
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              // Add Item row
              children: [
                Expanded(
                  child: TextField(
                    // Item name add
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Nom de l'article"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    // Quantity add
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  // Add item button
                  onPressed: () {
                    _addItem(
                      nameController.text,
                      int.tryParse(quantityController.text) ?? 0,
                    );
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //displays a loading indicator while data is being fetched,
            //shows an error message if there's an error, displays a list of grocery items with their names,
            //quantities, and images if available, and shows a message if no data is available.
            //The GroceryItemRow widget is used to display individual grocery items.
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    groceryItems = snapshot.data!;
                    return ListView.builder(
                      itemCount: groceryItems.length,
                      itemBuilder: (context, index) {
                        String imageUrl =
                            'https://upload.wikimedia.org/wikipedia/commons/b/ba/Error-logo.png'; // Default image URL

                        // Check if imageUrl exists and is a list with at least one element
                        if (groceryItems[index]['imageUrl'] != null &&
                            groceryItems[index]['imageUrl'] is List &&
                            groceryItems[index]['imageUrl'].isNotEmpty) {
                          imageUrl = groceryItems[index]['imageUrl'][0];
                        }

                        return GroceryItemRow(
                          itemName: groceryItems[index]['name'],
                          quantity: groceryItems[index]['quantity'],
                          imageUrl: imageUrl,
                          itemId: groceryItems[index]['id'],
                          onDelete: _deleteItem,
                          onEdit: _editItem,
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text('Aucune donnée disponible.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // for all functions there, it request on 92.154.13.69:3000 server api
  // Function to call the delete all function if the confirmation is yes
  void _showDeleteAllConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer tous les éléments ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAllItems();
                Navigator.of(context).pop();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete all items from the list
  Future<void> _deleteAllItems() async {
    final url = Uri.parse('$apiBaseUrl/deleteAll');
    final response = await http.delete(url, headers: {
      'api-key': apiKey, // Add the API key to the headers
    });

    if (response.statusCode == 200) {
      // All items successfully deleted, handle UI update if needed
      print('All items deleted successfully');
      // Reload the data to refresh the list
      setState(() {
        // Call getData function to refresh the data
      });
    } else {
      // Error occurred while deleting items, handle error
      print('Failed to delete all items');
    }
  }

  // Function to add an item to the list
  Future<void> _addItem(String name, int quantity) async {
    final url = Uri.parse('$apiBaseUrl/AddItem');
    final response = await http.post(
      url,
      body: jsonEncode({'name': name, 'quantity': quantity}),
      headers: {
        'Content-Type': 'application/json',
        'api-key': apiKey, // Add the API key to the headers
      },
    );

    if (response.statusCode == 200) {
      // Item successfully added, handle UI update if needed
      print('Item $name added successfully');
      // Clear the input fields after adding the item
      nameController.clear();
      quantityController.clear();
      // Reload the data to refresh the list
      setState(() {
        // Call getData function to refresh the data
      });
    } else {
      // Error occurred while adding the item, handle error
      print('Failed to add item $name');
    }
  }

  //Function to get data from the API and fetch them as items
  Future<List<Map<String, dynamic>>> getData() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/items'));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('items')) {
        List<Map<String, dynamic>> items = List.from(responseData['items']);
        return items;
      } else {
        throw Exception('Invalid API response format: missing key "items"');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  //Function to delete a precise item
  Future<void> _deleteItem(int itemId) async {
    final url = Uri.parse('$apiBaseUrl/DeleteItem/$itemId');
    final response = await http.delete(url, headers: {
      'api-key': apiKey, // Add the API key to the headers
    });

    if (response.statusCode == 200) {
      // Item successfully deleted, handle UI update if needed
      print('Item $itemId deleted successfully');
      // Reload the data to refresh the list
      setState(() {
        // Call getData function to refresh the data
      });
    } else {
      // Error occurred while deleting the item, handle error
      print('Failed to delete item $itemId');
    }
  }

  //function to edit a precise item
  Future<void> _editItem(int itemId, String name, int quantity) async {
    final url = Uri.parse(
        '$apiBaseUrl/ChangeItem/$itemId?name=$name&quantity=$quantity');
    final response = await http.put(url,
        body: jsonEncode({'name': name, 'quantity': quantity}),
        headers: {
          'Content-Type': 'application/json',
          'api-key': apiKey, // Add the API key to the headers
        });

    if (response.statusCode == 200) {
      // Item successfully edited, handle UI update if needed
      print('Item $itemId edited successfully');
      // Reload the data to refresh the list
      setState(() {
        // Call getData function to refresh the data
      });
    } else {
      // Error occurred while editing the item, handle error
      print('Failed to edit item $itemId');
    }
  }
}

// DISPLAY the list of grocery. For each items, it will make a row with the image, name and quantity, edit and delete button.
class GroceryItemRow extends StatelessWidget {
  final String itemName;
  final int quantity;
  final String imageUrl;
  final int itemId; // ID of the item to be deleted
  final Function(int) onDelete;
  final Function(int, String, int) onEdit;

  GroceryItemRow({
    required this.itemName,
    required this.quantity,
    required this.imageUrl,
    required this.itemId,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Display the image (assuming imageUrl is a valid network image URL)
          Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 8),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Quantité: $quantity',
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          // Edit button
          ElevatedButton(
            onPressed: () {
              _showEditItemDialog(context);
            },
            child: const Text('Modifier'),
          ),
          const SizedBox(width: 8),
          // Delete button
          ElevatedButton(
            onPressed: () {
              // Call the delete function when the button is pressed
              onDelete(itemId);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Function to open a dialog pop up with a name and quantity text box. (=backend)
  void _showEditItemDialog(BuildContext context) {
    String editedName = itemName;
    int editedQuantity = quantity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditItemPopup(
          initialName: itemName,
          initialQuantity: quantity,
          onNameChanged: (String name) {
            editedName = name;
          },
          onQuantityChanged: (int quantity) {
            editedQuantity = quantity;
          },
          onConfirm: () {
            onEdit(itemId, editedName, editedQuantity);
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

// Function to open a dialog pop up with a name and quantity text box. (=frontend)
class EditItemPopup extends StatelessWidget {
  final String initialName;
  final int initialQuantity;
  final Function(String) onNameChanged;
  final Function(int) onQuantityChanged;
  final Function() onConfirm;
  final Function() onCancel;

  EditItemPopup({
    required this.initialName,
    required this.initialQuantity,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier l'article"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Nom de l'article"),
            controller: TextEditingController(text: initialName),
            onChanged: onNameChanged,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Quantité'),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: initialQuantity.toString()),
            onChanged: (value) {
              onQuantityChanged(int.tryParse(value) ?? 0);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
