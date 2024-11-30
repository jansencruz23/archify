import 'package:archify/components/my_button.dart';
import 'package:flutter/material.dart';

class MyFeedbackForm extends StatefulWidget {
  final Function(String subject, String body) onSubmit;

  const MyFeedbackForm({super.key, required this.onSubmit});

  @override
  State<MyFeedbackForm> createState() => _MyFeedbackFormState();
}

class _MyFeedbackFormState extends State<MyFeedbackForm> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Subject
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          SizedBox(height: 12,),
          //Body
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 5,
          ),
          //button that place the subject and body on the settings page query parameters
          MyButton(text: 'Submit', onTap: (){

            final subject = _subjectController.text;
            final body = _bodyController.text;
            widget.onSubmit(subject, body);
            Navigator.pop(context);
          })
        ],
      ),
    );
  }
}
