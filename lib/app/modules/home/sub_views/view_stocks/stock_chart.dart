// ignore_for_file: unnecessary_this
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/charts/my_line_chart.dart';
import 'package:money/app/core/widgets/dialog/dialog_single_text_input.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/core/widgets/working.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/get_stock_from_cache_or_backend.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

class ChartEvent {
  ChartEvent({
    required this.date,
    required this.amount,
    required this.quantity,
    required this.description,
    required this.colorBasedOnQuantity,
  });

  final double amount;
  final bool colorBasedOnQuantity;
  final DateTime date;
  final String description;
  final double quantity;

  Color get color => colorBasedOnQuantity
      ? (quantity == 0 ? Colors.grey : (isBuy ? Colors.orange : Colors.blue))
      : (amount == 0 ? Colors.grey : (amount.isNegative ? Colors.orange : Colors.blue));

  bool get isBuy => quantity > 0;

  bool get isSell => quantity < 0;
}

class StockChartWidget extends StatefulWidget {
  const StockChartWidget({
    super.key,
    required this.symbol,
    required this.splits,
    required this.dividends,
    required this.holdingsActivities,
  });

  final List<Dividend> dividends;
  final List<ChartEvent> holdingsActivities;
  final List<StockSplit> splits;
  final String symbol;

  @override
  StockChartWidgetState createState() => StockChartWidgetState();
}

class StockChartWidgetState extends State<StockChartWidget> {
  List<FlSpot> dataPoints = [];
  StockPriceHistoryCache latestPriceHistoryData = StockPriceHistoryCache('', StockLookupStatus.notFoundInCache, null);

  late Security? security = Data().securities.getBySymbol(widget.symbol);

  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _getStockHistoricalData();
  }

  @override
  Widget build(BuildContext context) {
    if (security == null) {
      return CenterMessage(message: 'Security "${widget.symbol}" is not valid');
    }

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

  void fromPriceHistoryToChartDataPoints(StockPriceHistoryCache priceCache) {
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

    // lines are drawn let to right sorted by time
    // the labels are drawn bottom to top sorted by ascending currentUnitPrice
    widget.holdingsActivities.sort((a, b) => a.amount.compareTo(b.amount));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Splits
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintSplits(
              splits: widget.splits,
              minX: dataPoints.first.x,
              maxX: dataPoints.last.x,
            ),
          ),
        ),

        // Activities Buy & Sell
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

        // Dividends
        Padding(
          padding: const EdgeInsets.only(left: marginLeft, bottom: marginBottom),
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: PaintDividends(
              list: widget.dividends,
              minX: dataPoints.first.x,
              maxX: dataPoints.last.x,
            ),
          ),
        ),
        MyLineChart(dataPoints: dataPoints, showDots: false),

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
    return scaleDown(
      IntrinsicWidth(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
                child: _refreshing ? const CupertinoActivityIndicator() : const Icon(Icons.refresh_outlined),
              ),
              Text(getElapsedTime(latestPriceHistoryData.lastDateTime)),
            ],
          ),
          onPressed: () async {
            setState(() {
              _refreshing = true;
            });
            loadFomBackendAndSaveToCache(widget.symbol).then((result) async {
              fromPriceHistoryToChartDataPoints(await loadFomBackendAndSaveToCache(widget.symbol));

              // Fetch Historical Stock Splits
              List<StockSplit> splits = [];
              if (PreferenceController.to.useYahooStock.value) {
                splits = await _fetchStockSplitsFromYahoo(widget.symbol);
              } else {
                splits = await _fetchSplitsFromTwelveData(widget.symbol);
              }

              setState(() {
                _refreshing = false;

                fromPriceHistoryToChartDataPoints(result);

                // update the data model
                Data().stockSplits.setStockSplits(security!.uniqueId, splits);

                // refresh all of the UI part since if needed
                if (DataController.to.trackMutations.isMutated()) {
                  Data().updateAll();
                }
              });
            });
          },
        ),
      ),
    );
  }

  Future<List<StockSplit>> _fetchSplitsFromTwelveData(
    String symbol,
  ) async {
    List<StockSplit> splitsFound = [];

    if (PreferenceController.to.apiKeyForStocks.isNotEmpty) {
      final Uri uri = Uri.parse(
        'https://api.twelvedata.com/splits?symbol=$symbol&range=full&apikey=${PreferenceController.to.apiKeyForStocks}',
      );

      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        try {
          final MyJson data = json.decode(response.body);

          int? subStatusCode = data['code'];
          if ([401, 403, 404, 409].contains(subStatusCode)) {
            logger.e(data.toString());
            SnackBarService.displayError(message: data['message']);
          } else {
            final List<dynamic> dataSplits = data['splits'];

            final securityId = Data().securities.getBySymbol(symbol)!.uniqueId;
            for (final dataSplit in dataSplits) {
              final dateOfSplit = DateTime.parse(dataSplit['date']);
              StockSplit sp = StockSplit(
                security: securityId,
                date: dateOfSplit,
                numerator: dataSplit['from_factor'],
                denominator: dataSplit['to_factor'],
              );
              splitsFound.add(sp);
            }
          }
        } catch (error) {
          logger.e(error.toString());
          SnackBarService.displayError(message: error.toString());
        }
      } else {
        logger.e('Failed to fetch data: ${response.toString()}');
      }
    }
    return splitsFound;
  }

  Future<List<StockSplit>> _fetchStockSplitsFromYahoo(String symbol) async {
    List<StockSplit> splitsFound = [];

    // Base URL for Yahoo Finance API v8
    final String baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/$symbol';

    // Define the query parameters
    final Map<String, String> queryParams = {
      'interval': '1d', // Daily interval
      'range': '5y', // Last 5 years range
      'events': 'splits', // Fetch stock splits
    };

    // Construct the full URL with query parameters
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    // Send the GET request to the Yahoo Finance API
    final http.Response response = await http.get(uri);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the response body as JSON
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Security? security = Data().securities.getBySymbol(symbol);
      if (security != null) {
        // Extract the stock splits data
        final responseChart = jsonResponse['chart'];
        if (responseChart != null) {
          final responseChartResult = responseChart['result'];
          if (responseChartResult != null) {
            if ((responseChartResult is List) && responseChartResult.isNotEmpty) {
              final firstEntry = responseChartResult.firstOrNull;
              if (firstEntry != null) {
                final events = firstEntry['events'];
                if (events != null) {
                  final splits = events['splits'];
                  if (splits != null) {
                    for (var splitJson in splits.values) {
                      int dateInMiliseconds = splitJson['date'];
                      final dateOSplit = DateTime.fromMillisecondsSinceEpoch(dateInMiliseconds * 1000);
                      StockSplit sp = StockSplit(
                        security: security.uniqueId,
                        date: dateOSplit,
                        numerator: splitJson['numerator'].toInt(),
                        denominator: splitJson['denominator'].toInt(),
                      );
                      splitsFound.add(sp);
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        // Handle the error
        logger.e('Failed to load stock splits for $symbol');
      }
    }
    return splitsFound;
  }

  void _getStockHistoricalData() async {
    StockPriceHistoryCache priceCache = await getFromCacheOrBackend(widget.symbol);
    fromPriceHistoryToChartDataPoints(priceCache);
  }
}

/// A reusable Paint object for drawing filled rectangles.
final ui.Paint _paint = Paint()..style = PaintingStyle.fill;

void _paintLine(
  ui.Canvas canvas,
  Color color,
  double left,
  double top,
  double chartHeight,
) {
  final rect = Rect.fromLTWH(left, top, 0.5, chartHeight);
  _paint.color = color;

  canvas.drawRect(rect, _paint);
}

void _paintLabel(
  ui.Canvas canvas,
  String text,
  Color color,
  double x,
  double y,
) {
  // Draw the text
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 9,
        height: 0.9, // Tight lines spacing
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  );

  textPainter.layout(
    minWidth: 0,
    maxWidth: 400,
  );

  textPainter.paint(canvas, Offset(x, y));
}

class PaintSplits extends CustomPainter {
  PaintSplits({
    required this.splits,
    required this.minX,
    required this.maxX,
  });

  final double maxX;
  final double minX;
  final List<StockSplit> splits;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    // lines are drawn lef to right sorted by time
    // the label are drawn bottom to top sorted by ascending amount
    for (final split in splits) {
      double left = 0;
      if (split.fieldDate.value!.millisecondsSinceEpoch > minX) {
        left = ((split.fieldDate.value!.millisecondsSinceEpoch - minX) / (maxX - minX)) * chartWidth;
      }
      _paintLine(canvas, Colors.grey, left, chartHeight - 5, 45);
      _paintLabel(
        canvas,
        '${split.fieldNumerator.value} for ${split.fieldDenominator.value}',
        Colors.blue,
        left + 2,
        chartHeight + 30,
      );
      left += 20;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PaintActivities extends CustomPainter {
  PaintActivities({
    required this.activities,
    required this.minX,
    required this.maxX,
    this.lineColor,
  });

  final List<ChartEvent> activities;
  final Color? lineColor;
  final double maxX;
  final double minX;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    double labelVerticalDistribution = chartHeight / activities.length;
    double nextVerticalLabelPosition = chartHeight - labelVerticalDistribution;

    for (final ChartEvent activity in activities) {
      double left = 0;

      if (activity.date.millisecondsSinceEpoch > minX) {
        left = ((activity.date.millisecondsSinceEpoch - minX) / (maxX - minX)) * chartWidth;
      }
      _paintLine(canvas, lineColor?.withAlpha(150) ?? activity.color.withOpacity(0.8), left, 0, chartHeight);

      String text = '';
      if (activity.quantity.toInt().abs() != 1) {
        text = '${getIntAsText(activity.quantity.toInt().abs())} ';
      }
      text += doubleToCurrency(activity.amount, showPlusSign: true);
      if (activity.description.isNotEmpty) {
        text += '\n${activity.description}';
      }

      _paintLabel(
        canvas,
        text,
        lineColor ?? activity.color,
        left + 2,
        nextVerticalLabelPosition,
      );

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
}

class PaintDividends extends CustomPainter {
  PaintDividends({
    required this.list,
    required this.minX,
    required this.maxX,
  });

  final List<Dividend> list;
  final double maxX;
  final double minX;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    // lines are drawn lef to right sorted by time
    // the label are drawn at bottom
    for (final item in list) {
      double left = 0;
      if (item.date.millisecondsSinceEpoch > minX) {
        left = ((item.date.millisecondsSinceEpoch - minX) / (maxX - minX)) * chartWidth;
      }
      _paintLine(canvas, Colors.grey, left, chartHeight - 5, 45);
      _paintLabel(
        canvas,
        Currency.getAmountAsStringUsingCurrency(item.amount),
        Colors.green,
        left + 2,
        chartHeight + 30,
      );
      left += 20;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
