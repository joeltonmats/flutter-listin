import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listin/features/authentication/services/auth_service.dart';
import 'package:listin/features/authentication/widgets/confirmation.dart';
import 'package:listin/features/home/models/listin.dart';
import 'package:listin/features/home/services/listin_service.dart';
import 'package:listin/features/product/screens/product_screen.dart';
import 'package:listin/features/profile/screens/profile_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  ListinService listinService = ListinService();

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: (widget.user.photoURL != null)
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
              ),
              accountName: Text(
                (widget.user.displayName != null)
                    ? widget.user.displayName!
                    : "",
              ),
              accountEmail: Text(widget.user.email!),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Change profile picture"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove account"),
              onTap: () {
                showPasswordConfirmationDialog(context: context, email: "");
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign out"),
              onTap: () {
                AuthService().signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text("Listin - Sharable Market")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "No lists yet.\nLet's create the first one?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(listListins.length, (index) {
                  Listin model = listListins[index];
                  return Dismissible(
                    key: ValueKey<Listin>(model),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductScreen(listin: model),
                          ),
                        );
                      },
                      onLongPress: () {
                        showFormModal(model: model);
                      },
                      leading: const Icon(Icons.list_alt_rounded),
                      title: Text(model.name),
                      // subtitle: Text(model.id),
                    ),
                  );
                }),
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels to be shown in the Modal
    String labelTitle = "Add Listin";
    String labelConfirmationButton = "Save";
    String labelSkipButton = "Cancel";

    // Controller for the field that will receive the Listin name
    TextEditingController nameController = TextEditingController();

    // If editing
    if (model != null) {
      labelTitle = "Editing ${model.name}";
      nameController.text = model.name;
    }

    // Flutter function that shows the modal on the screen
    showModalBottomSheet(
      context: context,

      // Set vertical borders to be rounded
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Form with Title, Field, and Buttons
          child: ListView(
            children: [
              Text(
                labelTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Listin Name")),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Create a Listin object with the info
                      Listin listin = Listin(
                        id: const Uuid().v1(),
                        name: nameController.text,
                      );

                      // Use id from model
                      if (model != null) {
                        listin.id = model.id;
                      }

                      // Save to Firestore
                      listinService.addListin(listin: listin);

                      // Update the list
                      refresh();

                      // Close the Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> listinsList = await listinService.readListins();
    setState(() {
      listListins = listinsList;
    });
  }

  void remove(Listin model) async {
    await listinService.removeListin(listinId: model.id);
    refresh();
  }
}
