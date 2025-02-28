import 'package:flutter/material.dart';
import 'sql_helper2.dart';

class ShowTask2 extends StatefulWidget {
  const ShowTask2({super.key});

  @override
  State<ShowTask2> createState() => _ShowTask2State();
}

class _ShowTask2State extends State<ShowTask2> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  void refreshContacts() async {
    final data = await SqlHelper2.getContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  void showForm(int? id) {
    if (id != null) {
      final existingContact = _contacts.firstWhere(
        (element) => element['id'] == id,
      );
      firstNameController.text = existingContact['first_name'];
      lastNameController.text = existingContact['last_name'];
      emailController.text = existingContact['email'];
      phoneController.text = existingContact['phone'];
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      phoneController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder:
          (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (firstNameController.text.isEmpty ||
                        lastNameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter all fields'),
                        ),
                      );
                      return;
                    }

                    if (id == null) {
                      await addContact();
                    } else {
                      await updateContact(id);
                    }

                    Navigator.of(context).pop(); // ปิด modal
                  },
                  child: Text(id == null ? 'Create New' : 'Update'),
                ),
              ],
            ),
          ),
    );
  }

  void _showContactDetails(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Contact Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("First Name: ${contact['first_name']}"),
                Text("Last Name: ${contact['last_name']}"),
                Text("Email: ${contact['email']}"),
                Text("Phone: ${contact['phone']}"),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
    );
  }

  Future<void> addContact() async {
    await SqlHelper2.insertContact({
      'first_name': firstNameController.text,
      'last_name': firstNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });
    refreshContacts();
  }

  Future<void> updateContact(int id) async {
    await SqlHelper2.updateContact(id, {
      'first_name': firstNameController.text,
      'last_name': firstNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });
    refreshContacts();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text(
              "Are you sure you want to delete this contact?",
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  await SqlHelper2.deleteContact(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact deleted!')),
                  );
                  refreshContacts();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showForm(null),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contacts.isEmpty
              ? const Center(
                child: Text(
                  'No contacts available',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder:
                    (context, index) => Card(
                      color: Colors.amber,
                      margin: const EdgeInsets.all(15),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            "${_contacts[index]['first_name']} ${_contacts[index]['last_name']}",
                          ),
                          subtitle: Text(
                            "📧 ${_contacts[index]['email']}\n📞 ${_contacts[index]['phone']}",
                          ),
                          trailing: SizedBox(
                            width: 120, // Increased width to avoid overflow
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.info),
                                    onPressed:
                                        () => _showContactDetails(
                                          _contacts[index],
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed:
                                        () => showForm(_contacts[index]['id']),
                                    icon: const Icon(Icons.edit),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed:
                                        () => confirmDelete(
                                          _contacts[index]['id'],
                                        ),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
    );
  }
}
