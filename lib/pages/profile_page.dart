import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadUserMoments();
    });
  }

  Future<void> _loadUserMoments() async {
    await _userProvider.loadUserMoments();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }
  final List<Map<String, String>> sampleGridData = [
    {
      'image': 'https://images.pexels.com/photos/29480524/pexels-photo-29480524/free-photo-of-majestic-white-pelican-near-lush-forest-pond.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'image': 'https://images.pexels.com/photos/9980507/pexels-photo-9980507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'image': 'https://images.pexels.com/photos/9980507/pexels-photo-9980507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'image': 'https://images.pexels.com/photos/9980507/pexels-photo-9980507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'image': 'https://images.pexels.com/photos/9980507/pexels-photo-9980507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'image': 'https://images.pexels.com/photos/9980507/pexels-photo-9980507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
  ];
  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;
    final days = listeningProvider.moments;

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
                            onTap: () {},
                            padding: 8,
                          )),
                    ),

                  )),body: MasonryGridView.builder(gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  shrinkWrap: true,
                  itemCount: sampleGridData.length ?? 0,//sample
                  itemBuilder: (context, index){
                    final imagePath = sampleGridData[index]['image']; //sample
                    if (imagePath == null)  return SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          imagePath, //sample
                          width: double.infinity,
                          height:
                          (index % 3 == 0) ? 180 : 230,
                          fit: BoxFit.cover,
                        ),

                      ),
                    );
                  }
              ),
            ));
    });
  }
}
