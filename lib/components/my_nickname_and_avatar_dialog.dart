import 'package:archify/components/my_button.dart';
import 'package:archify/helpers/avatar_mapper.dart';
import 'package:flutter/material.dart';

class MyNicknameAndAvatarDialog extends StatefulWidget {
  final void Function() onSubmit;
  final TextEditingController nicknameController;
  final TextEditingController avatarController;

  const MyNicknameAndAvatarDialog({
    super.key,
    required this.nicknameController,
    required this.avatarController,
    required this.onSubmit,
  });

  @override
  State<MyNicknameAndAvatarDialog> createState() =>
      _MyNicknameAndAvatarDialogState();
}

class _MyNicknameAndAvatarDialogState extends State<MyNicknameAndAvatarDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> focusNotifier = ValueNotifier<bool>(false);

  final avatarPaths = avatarMap;

  late String selectedAvatarPath;
  late String selectedAvatarId;
  late final FocusNode _fieldNickname;

  @override
  void initState() {
    super.initState();
    _fieldNickname = FocusNode();
    selectedAvatarId = avatarPaths.entries.first.key;
    widget.avatarController.text = selectedAvatarId;
    selectedAvatarPath =
        avatarPaths.entries.first.value; // Default avatar selection
    _fieldNickname.addListener(() {
      focusNotifier.value = _fieldNickname.hasFocus;
    });
  }

  @override
  void dispose() {
    _fieldNickname.dispose();
    focusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).colorScheme.tertiary;
    final focusColor = Theme.of(context).colorScheme.secondaryFixedDim;

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 0, right: 10, bottom: 0, left: 10),
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF5DEB3),
                      Color(0xFFD2691E),
                      Color(0xFFFF6F61),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    selectedAvatarPath,
                    fit: BoxFit.cover,
                    height: 60.0,
                    width: 60.0,
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: fillColor,
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: focusNotifier,
                      builder: (context, hasFocus, child) {
                        final defaultDecoration = InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          fillColor: hasFocus ? focusColor : fillColor,
                          filled: true,
                          hintText: 'Nickname',
                          contentPadding: const EdgeInsets.only(left: 30),
                        );

                        return TextFormField(
                          controller: widget.nicknameController,
                          focusNode: _fieldNickname,
                          decoration: defaultDecoration,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nickname is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 40,
            thickness: 1,
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: avatarPaths.length,
              itemBuilder: (context, index) {
                final avatarId = avatarMap.keys.elementAt(index);
                final avatarPath = avatarMap[avatarId]!;
                final isSelected = selectedAvatarPath == avatarMap[avatarId];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatarPath = avatarPath;
                      selectedAvatarId = avatarId;
                      widget.avatarController.text = selectedAvatarId;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: ClipOval(
                        child: Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          height: 20.0,
                          width: 20.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedAvatarPath.isEmpty) {
                // Show an alert if no photo is selected
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('No Photo Selected'),
                    content: Text('Please select a photo before confirming.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                String nickname = widget.nicknameController.text.trim();
                if (nickname.isEmpty) {
                  // Show alert if nickname is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Nickname Required'),
                      content:
                          Text('Please enter a nickname before confirming.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Confirmation dialog
                  widget.onSubmit();
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              'Confirm Selection',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }
}
