import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//AAlfonso Initial GridView
class MyGridView extends StatelessWidget {
  final List<String> photos;
  final List<String> avatars;
  final List<String> nicknames;
  final bool showNickname;
  final bool showLikeButton;
  final bool showDecorationBox;
  final double imageHeight;
  const MyGridView(
      {super.key,
      required this.photos,
      required this.avatars,
      required this.nicknames,
      this.showNickname = false,
      this.showLikeButton = false,
      this.showDecorationBox = false, this.imageHeight = 200.0});

  //AAlfonso For debugging
  void _likeImage(String imageUrl) {
    print("Liked: $imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
        gridDelegate:
            SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: photos.length,//occupy ng space needed lang
        itemBuilder: (context, index){
          final photo = photos[index];
          final avatar = avatars[index];
          final nickname = nicknames[index];

          return Container(
            decoration: showDecorationBox ? BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ):null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showNickname && nickname.isNotEmpty)
                Row(
                  children: [
                    if (avatar.isNotEmpty)
                      ClipOval(
                        child: Image.network(
                          photo,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12,),
                      Text(
                      nickname,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Sora',
                      ),
                    )

            ],


                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        photo,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: imageHeight, //argument nito (index % 3 == 0) ? 200 : 300, AALFONSO
                      ),

                    ),
                    if(showLikeButton)
                      Positioned(child:
                      GestureDetector(

                      ))
                  ],
                )
              ],
            ),

          );

        });
  }
}
