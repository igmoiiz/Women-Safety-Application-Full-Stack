import 'package:flutter/material.dart';
import 'package:women_safety/utils/custom_color.dart';

class CustomLinearProgress extends StatelessWidget {
  final double value;

  const CustomLinearProgress({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate number of ticks to show based on progress value
    int ticksToShow = (value * 4).round(); // 4 pages total

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          bool isActive = index < ticksToShow;
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isActive ? CustomColor.greenColor : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: isActive ? CustomColor.greenColor : Colors.white,
                ),
                child: isActive
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
              if (index < 3) // Don't show line after last tick
                Container(
                  width: 50,
                  height: 2,
                  color: index < (ticksToShow - 1)
                      ? CustomColor.greenColor
                      : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }
}
