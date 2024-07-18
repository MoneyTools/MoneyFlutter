// ignore_for_file: unnecessary_this
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/chart_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/core/widgets/chart.dart';
import 'package:money/app/core/widgets/dialog/dialog_single_text_input.dart';
import 'package:money/app/core/widgets/working.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/storage/get_stock_from_cache_or_backend.dart';

class HoldingActivity {
  HoldingActivity(this.date, this.amount, this.quantity);

  final double amount;
  final DateTime date;
  final double quantity;

  Color get color => quantity == 0 ? Colors.grey : (isBuy ? Colors.orange : Colors.blue);

  bool get isBuy => quantity > 0;

  bool get isSell => quantity < 0;
}

class StockChartWidget extends StatefulWidget {
  const StockChartWidget({
    super.key,
    required this.symbol,
    required this.holdingsActivities,
  });

  final List<HoldingActivity> holdingsActivities;
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
    _getStockHistoricalData();
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
      case StockLookupStatus.invalidSymbol:
        return _buildChart();
      default:
        return const WorkingIndicator();
    }
  }

  String getActivityQuantity(final int fromMillisecondsSinceEpoch) {
    final activityFound =
        widget.holdingsActivities.firstWhereOrNull((a) => a.date.millisecondsSinceEpoch == fromMillisecondsSinceEpoch);
    if (activityFound == null) {
      return '';
    }
    return '${getIntAsText(activityFound.quantity.toInt())} shares';
  }

  void _adjustMissingDataPointInthePast() {
    for (final activiy in widget.holdingsActivities.reversed) {
      if (dataPoints.isEmpty || activiy.date.millisecondsSinceEpoch < dataPoints.first.x) {
        dataPoints.insert(
          0,
          FlSpot(
            activiy.date.millisecondsSinceEpoch.toDouble(),
            activiy.amount,
          ),
        );
      }
    }
  }

  Widget _buildChart() {
    const double marginLeft = 80;
    const double marginBottom = 50;

    // Date ascending
    dataPoints.sort((a, b) => a.x.compareTo(b.x));

    _adjustMissingDataPointInthePast();

    if (dataPoints.isEmpty) {
      return const CenterMessage(message: 'No data points');
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintActivities(
              activities: widget.holdingsActivities,
              minX: dataPoints.first.x,
              maxX: dataPoints.last.x,
            ),
          ),
        ),
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
                  reservedSize: marginLeft,
                  getTitlesWidget: getWidgetChartAmount,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: marginBottom,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == meta.min || value == meta.max) {
                      return const SizedBox();
                    }
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      DateFormat('yyyy\nMMM').format(date),
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
                      '${doubleToCurrency(touchedSpot.y)}\n${dateToString(DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt()))}\n${getActivityQuantity(touchedSpot.x.toInt())}',
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

        /// Price and Refresh button
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: _buildPriceRefreshButton(),
        ),
      ],
    );
  }

  Widget _buildPriceRefreshButton() {
    if (dataPoints.isEmpty) {
      return CenterMessage(message: 'No history information about "${widget.symbol}"');
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: IntrinsicWidth(
        child: TextButton(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
                child: Text(
                  '${widget.symbol} ${doubleToCurrency(dataPoints.last.y)}',
                  style: const TextStyle(fontSize: SizeForText.large),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
                child: Icon(Icons.refresh_outlined),
              ),
              Text(getElapsedTime(latestPriceHistoryData.lastDateTime)),
            ],
          ),
          onPressed: () async {
            final result = await loadFomBackendAndSaveToCache(widget.symbol);
            _fromPriceHistoryToChartDataPoints(await loadFomBackendAndSaveToCache(widget.symbol));

            setState(() {
              _fromPriceHistoryToChartDataPoints(result);
            });
          },
        ),
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

  void _getStockHistoricalData() async {
    StockPriceHistoryCache priceCache = await getFromCacheOrBackend(widget.symbol);

    _fromPriceHistoryToChartDataPoints(priceCache);
  }
}

class PaintActivities extends CustomPainter {
  PaintActivities({
    required this.activities,
    required this.minX,
    required this.maxX,
  });

  final List<HoldingActivity> activities;
  final double maxX;
  final double minX;

  /// A reusable Paint object for drawing filled rectangles.
  final ui.Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    double labelVerticalDistribution = chartHeight / activities.length;
    double nextVerticalLabelPosition = chartHeight - labelVerticalDistribution;

    // lines are drawn lef to right sorted by time
    // the labe are drawn bottom to top sorted by ascending amount
    activities.sort((a, b) => a.amount.compareTo(b.amount));

    for (final HoldingActivity activity in activities) {
      double left = 0;

      if (activity.date.millisecondsSinceEpoch > minX) {
        left = ((activity.date.millisecondsSinceEpoch - minX) / (maxX - minX)) * chartWidth;
      }
      _paintLine(canvas, activity, left, chartHeight);
      _paintLabel(canvas, activity, left + 2, nextVerticalLabelPosition + (labelVerticalDistribution / 2));

      nextVerticalLabelPosition -= labelVerticalDistribution;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  /// Draws a filled rectangle on the given [canvas] with the specified [color],
  /// [left], [top], [width], and [height].
  ///
  /// This function reuses a single [Paint] object for better performance.
  void paintBox(
    ui.Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    Color color,
  ) {
    final rect = Rect.fromLTWH(left, top, width, height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _paintLabel(
    ui.Canvas canvas,
    HoldingActivity activity,
    double x,
    double y,
  ) {
    // Draw the text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${getIntAsText(activity.quantity.toInt().abs())} ${doubleToCurrency(activity.amount)}',
        style: TextStyle(
          color: activity.color,
          fontSize: 9,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 100,
    );

    textPainter.paint(canvas, Offset(x, y));
  }

  void _paintLine(
    ui.Canvas canvas,
    HoldingActivity activity,
    double left,
    double chartHeight,
  ) {
    final rect = Rect.fromLTWH(left, 0, 1, chartHeight);
    _paint.color = activity.color.withOpacity(0.8);

    canvas.drawRect(rect, _paint);
  }
}
