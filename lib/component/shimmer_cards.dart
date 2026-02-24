import 'package:flutter/material.dart';
import 'package:appex_lead/main.dart';
import 'package:shimmer/shimmer.dart';

class ResusableCard3Shimmer extends StatelessWidget {
  const ResusableCard3Shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colorManager.bgLight,
      highlightColor: colorManager.borderColor,
      child: ListView.builder(
        itemCount: 20,
        // padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, i) {
          return Container(
            width: double.infinity,
            height: 90,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: colorManager.bgDark,
            ),
          );
        },
      ),
    );
  }
}

class PlainShimmerCard extends StatelessWidget {
  final Widget? child;
  const PlainShimmerCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colorManager.bgLight,
      highlightColor: colorManager.borderColor,
      child: Container(
        decoration: BoxDecoration(
          color: colorManager.bgDark,
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}
