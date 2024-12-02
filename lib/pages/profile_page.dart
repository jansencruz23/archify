import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(180),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: AppBar(
                      leadingWidth: 120,
                      toolbarHeight: 75,
                      titleSpacing: 0,
                      leading: MyProfilePicture(
                        height: 150,
                        width: 120,
                        onProfileTapped: () {},
                        hasBorder: true,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              userProfile == null
                                  ? 'Loading'
                                  : userProfile.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontSize: 18,
                              )),
                          Text(
                            userProfile == null ? 'Loading' : userProfile.bio,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                      bottom: PreferredSize(
                          preferredSize: Size.fromHeight(30),
                          child: MyButton(
                            text: 'Edit Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfilePage()),
                              );
                            },
                            padding: 8,
                          )),
                    ),
                  )),
            ));
    });
  }
}
