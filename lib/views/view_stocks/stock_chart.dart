// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/get_stock_from_cache_or_backend.dart';
import 'package:money/widgets/chart.dart';

class StockChartWidget extends StatefulWidget {
  final String symbol;

  const StockChartWidget({super.key, required this.symbol});

  @override
  StockChartWidgetState createState() => StockChartWidgetState();
}

class StockChartWidgetState extends State<StockChartWidget> {
  List<FlSpot> dataPoints = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getStockHistoricalData();
  }

  void getStockHistoricalData() async {
    // Do we have the API Key to start
    if (Settings().apiKeyForStocks.isEmpty) {
      setState(() {
        this.errorMessage = 'Please setup the API Key for accessing twelvedata.com.';
      });
      return;
    }

    List<StockPrice> dateAndPrices = [];
    StockLookup status = await getFromCacheOrBackend(widget.symbol, dateAndPrices);
    if (status == StockLookup.validSymbol) {
      List<FlSpot> tmpDataPoints = [];
      for (final sp in dateAndPrices) {
        tmpDataPoints.add(FlSpot(sp.date.millisecondsSinceEpoch.toDouble(), sp.price));
      }

      setState(() {
        this.dataPoints = tmpDataPoints;
      });
    } else {
      setState(() {
        this.errorMessage = status == StockLookup.invalidSymbol ? 'Invalid Symbol "${widget.symbol}"' : '';
        this.dataPoints = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            isCurved: true,
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
              return Text(date.month.toString()); // Format as HH:MM
            },
          )),
        ),
        borderData: getBorders(0, 0),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
