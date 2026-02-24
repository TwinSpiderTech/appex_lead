import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomLineChart extends StatelessWidget {
  final List<dynamic> chartData;
  final Color? color;

  CustomLineChart({required this.chartData, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < chartData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          chartData[value.toInt()]["product_name"],
                          style: primaryTextStyle.copyWith(
                            color: colorManager.textColor,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: chartData.asMap().entries.map((entry) {
                  int index = entry.key;
                  double percentage = entry.value["percentage"]
                      .ceil()
                      .toDouble();
                  return FlSpot(index.toDouble(), percentage);
                }).toList(),
                isCurved: true,
                color: color ?? colorManager.primaryColor,
                barWidth: 4,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: !colorManager.isDark
                        ? [
                            colorManager.primaryColor.withOpacity(0.4),
                            colorManager.primaryColor.withOpacity(0),
                          ]
                        : [
                            colorManager.primaryColor.withOpacity(0.4),
                            colorManager.primaryColor.withOpacity(0),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final title =
                        chartData[touchedSpot.spotIndex]["tooltip"]['title'];
                    final description =
                        chartData[touchedSpot
                            .spotIndex]["tooltip"]['percentage'];
                    return LineTooltipItem(
                      '$title\n$description',
                      primaryTextStyle.copyWith(
                        color: !colorManager.isDark
                            ? colorManager.primaryColor
                            : Colors.white,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
