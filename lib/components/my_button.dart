import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({super.key, required this.text, this.onTap});

  @override
  State<MyButton> createState() => _MyButtonState();
}

bool amIHovering = false;
Offset exitFrom = Offset(0, 0);

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (PointerEvent details) => setState(() => amIHovering = true),

          // callback when your mouse pointer leaves the underlying widget
          onExit: (PointerEvent details) {
            setState(() {
              amIHovering = false;
              // Storing the exit position
              exitFrom = details.localPosition;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: amIHovering
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                    fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
