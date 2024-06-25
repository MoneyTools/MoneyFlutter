// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/data/storage/get_stock_from_cache_or_backend.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/dialog/dialog_single_text_input.dart';

class StockChartWidget extends StatefulWidget {
  final String symbol;

  const StockChartWidget({super.key, required this.symbol});

  @override
  StockChartWidgetState createState() => StockChartWidgetState();
}

class StockChartWidgetState extends State<StockChartWidget> {
  List<FlSpot> dataPoints = [];
  String errorMessage = '';
  StockLookupStatus lastStatus = StockLookupStatus.notFoundInCache;

  @override
  void initState() {
    super.initState();
    getStockHistoricalData();
  }

  void getStockHistoricalData() async {
    // Do we have the API Key to start
    if (PreferenceController.to.apiKeyForStocks.value.isEmpty) {
      setState(() {
        this.errorMessage = 'Please setup the API Key for accessing https://twelvedata.com.';
      });
      return;
    }

    List<StockPrice> dateAndPrices = [];
    StockLookupStatus status = await getFromCacheOrBackend(widget.symbol, dateAndPrices);
    if (status == StockLookupStatus.validSymbol || status == StockLookupStatus.foundInCache) {
      List<FlSpot> tmpDataPoints = [];
      for (final sp in dateAndPrices) {
        tmpDataPoints.add(FlSpot(sp.date.millisecondsSinceEpoch.toDouble(), sp.price));
      }
      if (mounted) {
        setState(() {
          this.dataPoints = tmpDataPoints;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          this.lastStatus = status;
          this.errorMessage = status == StockLookupStatus.invalidSymbol ? 'Invalid Symbol "${widget.symbol}"' : '';
          this.dataPoints = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PreferenceController.to.apiKeyForStocks.value.isEmpty || lastStatus == StockLookupStatus.invalidApiKey) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            showTextInputDialog(
              context: context,
              title: 'API Key',
              initialValue: PreferenceController.to.apiKeyForStocks.value,
              onContinue: (final String text) {
                PreferenceController.to.apiKeyForStocks.value = text;
              },
            );
          },
          child: const Text('Set API Key'),
        ),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Center(
          child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.orange),
      ));
    }

    if (dataPoints.isEmpty) {
      return const Center(child: Text('loading...'));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: false,
            color: Colors.blue,
            barWidth: 1,
            belowBarData: BarAreaData(show: false),
            dotData: const FlDotData(show: false), // Hide dots at endpoints
          ),
        ],
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(), // hide
          rightTitles: const AxisTitles(), // hide
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: getWidgetChartAmount,
            ),
          ),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value == meta.min || value == meta.max) {
                return const SizedBox();
              }
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(formatDate(date),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)); // Format as HH:MM
            },
          )),
        ),
        borderData: getBorders(0, 0),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy\nMMM').format(date);
}
