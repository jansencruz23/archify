import 'package:archify/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth/auth_provider.dart';
import '../services/auth/auth_service.dart';
import '../services/database/user/user_provider.dart';

class MyFeedbackForm extends StatefulWidget {
  final Function(String subject, String body) onSubmit;

  const MyFeedbackForm({super.key, required this.onSubmit});

  @override
  State<MyFeedbackForm> createState() => _MyFeedbackFormState();
}

class _MyFeedbackFormState extends State<MyFeedbackForm> {
  String? subject = '';
  String? body = '';
  String? _email;
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late TextEditingController _subjectController = TextEditingController();
  late TextEditingController _bodyController = TextEditingController();

  //Text field focus
  final FocusNode _fieldSubject = FocusNode();
  final FocusNode _fieldBody = FocusNode();

  Future<void> _fetchUserEmail() async {
    final user = AuthService().getCurrentUser();
    debugPrint('User: $user');
    debugPrint('User Email: ${user?.email}');
    setState(() {
      _email = user?.email ?? 'Email not available';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _bodyController = TextEditingController();
    _subjectController = TextEditingController();
    super.initState();
  }

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  void dispose() {
    _fieldSubject.dispose();
    _fieldBody.dispose();
    super.dispose();
  }

  void _unfocusAllFields() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: GestureDetector(
        onTap: _unfocusAllFields,
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 30.0, right: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0,),
                  child: Text(
                    'Got Feedback? Submit it here.',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.08),
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                //Subject
                //If mas maganda may text na "Subject sa taas"
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    // border: Border,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    focusNode: _fieldSubject,
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal)),
                    ),
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_fieldBody);
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 7,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                //Body
                //IF mas maganda pakita na may text na "Body"
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Body',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                TextField(
                  focusNode: _fieldBody,
                  controller: _bodyController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16.0),
                    labelText: 'Body',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal)),
                  ),
                  onSubmitted: (_) {
                    _fieldBody.unfocus();
                  },
                  maxLines: 5,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                //submit
                MyButton(
                    text: 'Submit',
                    onTap: () {
                      final subject = _subjectController.text;
                      final body = _bodyController.text;
                      widget.onSubmit(subject, body);
                      Navigator.pop(context);

                      String? encodeQueryParameters(
                          Map<String, String> params) {
                        return params.entries
                            .map((MapEntry<String, String> e) =>
                                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                            .join('&');
                      }

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'archify.app@gmail.com',
                        query: encodeQueryParameters(<String, String>{
                          'subject': subject, //gmail subject
                          'body': body //gmail
                        }),
                      );
                      launchUrl(emailLaunchUri);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
