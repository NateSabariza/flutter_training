import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/user_view_model.dart';
import '../../../ui/core/ui/loader.dart';
import 'user_profile_screen.dart';
import 'user_form.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the screen is loaded or revisited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<UserViewModel>(context, listen: false);
      vm.fetchUsers(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserViewModel>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: vm.isLoading
          ? const Loader()
          : vm.users.isEmpty
              ? const Center(
                  child: Text(
                    'No users available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: isLandscape ? 2 / 3 : 3 / 4,
                  ),
                  itemCount: vm.users.length,
                  itemBuilder: (context, index) {
                    final user = vm.users[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(user: user),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: isLandscape ? 250 : 140,
                                  child: Image.network(
                                    user.avatar,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        'https://previews.123rf.com/images/yehorlisnyi/yehorlisnyi2104/yehorlisnyi210400016/167492439-no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: -6,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'Edit') {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserFormScreen(
                                              userId: user.id,
                                              initialEmail: user.email,
                                              initialFirstName: user.firstName,
                                              initialLastName: user.lastName,
                                              initialAvatar: user.avatar,
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          final vm = Provider.of<UserViewModel>(context, listen: false);
                                          vm.fetchUsers();
                                        }
                                      } else if (value == 'Delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text('Are you sure you want to delete this user?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          final vm = Provider.of<UserViewModel>(context, listen: false);
                                          await vm.deleteUser(user.id);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('User Successfully Deleted')),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'Edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'Delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.8),
                                            spreadRadius: -6,
                                            blurRadius: 15,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserFormScreen(),
            ),
          );
          if (result == true) {
            final vm = Provider.of<UserViewModel>(context, listen: false);
            vm.fetchUsers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
