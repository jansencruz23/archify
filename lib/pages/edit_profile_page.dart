import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  late final UserProvider _userProvider;
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  String _imagePath = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
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
      _imagePath = userProfile.pictureUrl;
    }
  }

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      // Call your provider method to upload and update the profile picture
      // await _userProvider.updateUserProfilePicture(imageFile);

      setState(() {
        _imagePath = imageFile.path;
      });
    }
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _userProvider.updateUserProfile(
        name: _nameController.text,
        bio: _bioController.text,
        imagePath: _imagePath,
      );

      if (mounted) goProfile(context);
    }
  }

  void _cancelEdit() {
    goProfile(context);
  }

  //Out ng comment textfield pag click anywhere
  void _unfocusAllFields() {
    FocusScope.of(context).unfocus();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _unfocusAllFields();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 33.0),
            alignment: Alignment.centerLeft,
            child: const SafeArea(
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Consumer<UserProvider>(builder: (context, provider, child) {
                        return CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imagePath.startsWith('https')
                              ? Image.network(_imagePath).image
                              : Image.file(File(_imagePath)).image,
                        );
                      }),
                      FloatingActionButton.small(
                        onPressed:
                            _changeProfilePicture, // Trigger profile picture change
                        backgroundColor: const Color(0xFFFF6F61),
                        child:
                            const Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    focusNode: _nameFocus,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      fillColor: const Color(0xFFFAF4E8),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Color(0xFFFAF4E8), width: 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Color(0xFFFAF4E8), width: 2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    style: TextStyle(fontFamily: 'Sora', color: Theme.of(context).colorScheme.inversePrimary),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_bioFocus);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    focusNode: _bioFocus,
                    decoration: InputDecoration(
                      labelText: "Bio",
                      labelStyle: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      fillColor: const Color(0xFFFAF4E8),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Color(0xFFFAF4E8), width: 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Color(0xFFFAF4E8), width: 2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    style: TextStyle(fontFamily: 'Sora', color: Theme.of(context).colorScheme.inversePrimary),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a bio.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _cancelEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side:
                              const BorderSide(color: Color(0xFFFF6F61), width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFFFF6F61),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F61),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
