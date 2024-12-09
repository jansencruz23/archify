import 'package:archify/components/my_text_field.dart';
import 'package:archify/helpers/font_helper.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';

class SetupNamePage extends StatefulWidget {
  final UserProvider userProvider;
  final TextEditingController nameController;

  const SetupNamePage({
    super.key,
    required this.nameController,
    required this.userProvider,
  });

  @override
  State<SetupNamePage> createState() => _SetupNamePageState();
}

class _SetupNamePageState extends State<SetupNamePage> {
  late final FocusNode nameFocusNode;
  List<String> _nameSuggestions = [];
  String name = '';

  @override
  void initState() {
    nameFocusNode = FocusNode();
    super.initState();
    loadNameSuggestions();
  }

  Future<void> loadNameSuggestions() async {
    final nameSuggestions = await widget.userProvider.getRandomNames();
    setState(() {
      _nameSuggestions = nameSuggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final names = _nameSuggestions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 30),
              child: Text(
                'What should we call you?',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: getClampedFontSize(context, 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyTextField(
                controller: widget.nameController,
                hintText: 'Your Name',
                obscureText: false,
                focusNode: nameFocusNode,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    final name = names[index];

                    return ListTile(
                      title: Text(
                        names[index],
                        style: TextStyle(
                          fontFamily: 'Sora',
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      onTap: () {
                        widget.nameController.text = names[index];
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
