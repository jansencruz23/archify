import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Story',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Text(
              'Welcome to [App Name]! Our app was created with the mission of [briefly explain the mission and purpose of the app]. The idea came to life when [briefly explain the inspiration behind the app].\n\n'
                  'We believe that [key values or beliefs that the app represents, e.g., user-centric design, innovation, community-building, etc.]. Our team is passionate about [mention any key areas of expertise, such as technology, user experience, etc.], and we are dedicated to providing you with the best experience possible.\n\n'
                  'Thank you for being part of our journey and helping us grow!',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 32.0),
            Text(
              'Meet the Team',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Member 1
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/JCruz_img.png'), // Add the image asset path here
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '1. [Team Member Name] - [Role]\n'
                            '[Brief description about the team member, their contribution to the app, or interesting fact].',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                // Team Member 2
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/AAlfonso_img.png'), // Add the image asset path here
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '2. [Team Member Name] - [Role]\n'
                            '[Brief description about the team member, their contribution to the app, or interesting fact].',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                // Team Member 3
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/JSalem_img.png'), // Add the image asset path here
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '3. [Team Member Name] - [Role]\n'
                            '[Brief description about the team member, their contribution to the app, or interesting fact].',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
