import 'package:flutter/material.dart';

class EmptyDayPage extends StatelessWidget {
  const EmptyDayPage({super.key});

  //For Responsiveness ng appbar text
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(70), child: AppBar(
        titleSpacing: 0,
        leadingWidth: 600,
        leading: SizedBox(
          height: double.infinity,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0),child:
          Stack(
            children: [
              Text('Let’s keep the moment,', style: TextStyle(
                fontSize: _getClampedFontSize(context, 0.01),
                fontFamily: 'Sora',
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary,
              ),),
              Positioned(
                  bottom: 10,
                  left: 0,
                  child:

                  Text('Pick the best shot!', style: TextStyle(
                    fontSize: _getClampedFontSize(context, 0.06),
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary,
                  ),))
            ],
          ),),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      )),
      body: Center(
        child:
            Padding(
              padding: const EdgeInsets.all(36.0),
              child: Text('Pssst... the room\'s waiting for you. Got the code?',textAlign: TextAlign.center, style: TextStyle(
                  fontSize: _getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      color: Theme.of(context)
              .colorScheme
              .inversePrimary,
                    ),),
            ),
      ),
    );
  }
}
