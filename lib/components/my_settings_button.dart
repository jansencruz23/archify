import 'package:flutter/material.dart';

class MySettingsButton extends StatefulWidget {
  final String text;
  final Widget icon;
  final void Function()? onTap;
  final bool isEnabled;
  final bool isClicked;
  final bool isLongPressed;

  const MySettingsButton({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.isEnabled = true,
    this.isClicked = false,
    this.isLongPressed = false,
  });

  @override
  State<MySettingsButton> createState() => _MySettingsButtonState();
}

class _MySettingsButtonState extends State<MySettingsButton> {
  bool _isClicked = false;
  bool _isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onTap : null,
        // Only allow tap if enabled
        child: GestureDetector(
          onTap: () {
            if (widget.isEnabled) {
              // Check if enabled before responding to tap
              setState(() {
                _isClicked = !_isClicked;
              });
              if (widget.onTap != null) {
                widget.onTap!();
              }
              Future.delayed(Duration(milliseconds: 300), () {
                setState(() {
                  _isClicked = false;
                });
              });
            }
          },
          onLongPressStart: (_) {
            if (widget.isEnabled) {
              // Check if enabled before handling long press
              Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {
                  _isLongPressed = true;
                });
              });
            }
          },
          onLongPressEnd: (_) {
            if (widget.isEnabled) {
              // Check if enabled before handling long press end
              setState(() {
                _isLongPressed = false;
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(microseconds: 100),
            height: 50,
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? (_isLongPressed
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : _isClicked
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.surface)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.icon,
                  SizedBox(width: 15),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.isEnabled
                          ? Theme.of(context).colorScheme.inversePrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Sora',
                      fontSize: 18,
                    ),
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
