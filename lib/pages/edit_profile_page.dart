import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _userProvider.loadUserProfile();
    final userProfile = _userProvider.userProfile;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
      _bioController.text = userProfile.bio;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _userProvider.updateUserProfile(
        name: _nameController.text,
        bio: _bioController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1.0), // Light gray border
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: const SafeArea(
            child: Text(
              "Edit Profile", // Updated AppBar text
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black, // Black text
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture section
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: provider.userProfile?.pictureUrl != null
                            ? NetworkImage(provider.userProfile!.pictureUrl!)
                            : const AssetImage("assets/placeholder_profile.jpg")
                        as ImageProvider,
                      );
                    },
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      // Logic to change profile picture
                    },
                    backgroundColor: const Color(0xFFFF6F61),
                    child: const Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Bio field
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a bio.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Save button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F61),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white, // White text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
