// ignore_for_file: unnecessary_this

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/chart_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/dialog/dialog_single_text_input.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/icon_button.dart';
import 'package:money/app/data/storage/get_stock_from_cache_or_backend.dart';

class StockChartWidget extends StatefulWidget {
  const StockChartWidget({required this.symbol, super.key});

  final String symbol;

  @override
  StockChartWidgetState createState() => StockChartWidgetState();
}

class StockChartWidgetState extends State<StockChartWidget> {
  List<FlSpot> dataPoints = [];
  StockPriceHistoryCache latestPriceHistoryData = StockPriceHistoryCache('', StockLookupStatus.notFoundInCache, null);

  @override
  void initState() {
    super.initState();
    getStockHistoricalData();
  }

  @override
  Widget build(BuildContext context) {
    if (PreferenceController.to.apiKeyForStocks.isEmpty ||
        latestPriceHistoryData.status == StockLookupStatus.invalidApiKey) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            showTextInputDialog(
              context: context,
              title: 'API Key',
              subTitle: 'for accessing https://twelvedata.com',
              initialValue: PreferenceController.to.apiKeyForStocks,
              onContinue: (final String text) {
                PreferenceController.to.apiKeyForStocks = text;
              },
            );
          },
          child: const Text('Set API Key'),
        ),
      );
    }

    switch (latestPriceHistoryData.status) {
      case StockLookupStatus.foundInCache:
      case StockLookupStatus.validSymbol:
        return _buildChart();
      case StockLookupStatus.invalidSymbol:
        return Center(child: Text('Symbol "${latestPriceHistoryData.symbol.toUpperCase()}" not found.'));
      default:
        return const Center(child: Text('loading...'));
    }
  }

  void getStockHistoricalData() async {
    StockPriceHistoryCache priceCache = await getFromCacheOrBackend(widget.symbol);

    _fromPriceHistoryToChartDataPoints(priceCache);
  }

  Widget _buildChart() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        LineChart(
          LineChartData(
            lineBarsData: [
              getLineChartBarData(dataPoints),
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
                    return Text(
                      formatDate(date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ); // Format as HH:MM
                  },
                ),
              ),
            ),
            borderData: getBorders(0, 0),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                // tooltipBgColor: Colors.blueAccent,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      doubleToCurrency(touchedSpot.y),
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
              // touchCallback: (LineTouchResponse touchResponse) {},
              handleBuiltInTouches: true,
            ),
          ),
        ),
        _buildPriceRefreshButton(),
      ],
    );
  }

  Widget _buildPriceRefreshButton() {
    if (dataPoints.isEmpty) {
      return CenterMessage(message: 'No history information about "${widget.symbol}"');
    }
    return IntrinsicWidth(
      child: Row(
        children: [
          Text(
            'Price ${doubleToCurrency(dataPoints.last.y)}',
          ),
          gapMedium(),
          MyIconButton(
            icon: Icons.refresh_outlined,
            onPressed: () async {
              final result = await loadFomBackendAndSaveToCache(widget.symbol);
              _fromPriceHistoryToChartDataPoints(await loadFomBackendAndSaveToCache(widget.symbol));

              setState(() {
                _fromPriceHistoryToChartDataPoints(result);
              });
            },
          ),
          gapMedium(),
          Text(
            getElapsedTime(latestPriceHistoryData.lastDateTime),
          ),
        ],
      ),
    );
  }

  void _fromPriceHistoryToChartDataPoints(StockPriceHistoryCache priceCache) {
    if (priceCache.status == StockLookupStatus.validSymbol || priceCache.status == StockLookupStatus.foundInCache) {
      List<FlSpot> tmpDataPoints = [];
      for (final sp in priceCache.prices) {
        tmpDataPoints.add(FlSpot(sp.date.millisecondsSinceEpoch.toDouble(), sp.price));
      }
      if (mounted) {
        setState(() {
          this.latestPriceHistoryData = priceCache;
          this.dataPoints = tmpDataPoints;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          this.latestPriceHistoryData = priceCache;
          this.dataPoints = [];
        });
      }
    }
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy\nMMM').format(date);
}
