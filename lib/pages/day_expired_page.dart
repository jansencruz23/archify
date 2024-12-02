import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/day.dart';
import '../services/database/day/day_provider.dart';

class DayExpiredPage extends StatefulWidget {
  const DayExpiredPage({super.key,});


  @override
  State<DayExpiredPage> createState() => _DayExpiredPageState();
}

class _DayExpiredPageState extends State<DayExpiredPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Day? day;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //For Responsiveness ng appbar text
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    day = listeningProvider.day;
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
      body: Stack(
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context)
                      .colorScheme
                      .secondary,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('DAY CODE: ${day == null ? 'Loading' : day!.votingDeadline.toString()}',style: TextStyle(
                        fontSize: _getClampedFontSize(context, 0.03),
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .surface,
                      ),),
                ),
              ),
            )
          ],),
          Center(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('lib/assets/images/Trophy.png'),
                SizedBox(height: 10,),
                Text('The photo battle is over—see the winning moment!',textAlign: TextAlign.center, style: TextStyle(
                  fontSize: _getClampedFontSize(context, 0.05),
                  fontFamily: 'Sora',
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary,
                ),),
              ],
            ),
          ),
        ),
    ],
      ),
    );
  }
}
