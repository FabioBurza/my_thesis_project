import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final String title = 'Upload To GitHub';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IG Simulator',
      home: FutureBuilderClass(),
    );
  }
}

class FutureBuilderClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FutureBuilderClassState();
  }
}

class FutureBuilderClassState extends State<FutureBuilderClass> {
  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> getIG(
        List<double> B, List<double> CHO, int TIDSTEPS, double BW) async {
      Map input_par = {"B": B, "CHO": CHO, "TIDSTEPS": TIDSTEPS, "BW": BW};
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      final response =
          await dio.post('http://192.168.1.205:5000/', data: input_par);
      return response.data;
    }

    double BW = 70;
    int TIDSTEPS = 360;
    List<double> B = List.filled(TIDSTEPS, 0, growable: false);
    B[50] = 5 * 1000 / BW;
    List<double> CHO = List.filled(TIDSTEPS, 0, growable: false);
    CHO[50] = 50 * 1000 / BW;

    List<Point> getPoints(List<double> IG) {
      List<Point> points_list = [];
      for (int i = 0; i < TIDSTEPS; i++) {
        points_list.add(Point(i, IG[i]));
      }

      return points_list;
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Center(
            child: Text(
              'IG Plot',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        //backgroundColor:,
        body: SafeArea(
          child: Container(
              color: Colors.white,
            child: FutureBuilder<List<dynamic>>(
                future: getIG(B, CHO, TIDSTEPS, BW),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // print(snapshot.data.runtimeType);
                    List<double> IG = (snapshot.data!).cast<double>().toList();
                    double lim_max = 180;
                    double lim_min = 70;
                    List<double> IG_max =
                        List.filled(TIDSTEPS, lim_max, growable: false);
                    List<double> IG_min =
                        List.filled(TIDSTEPS, lim_min, growable: false);
                    List<Point> IG_points = getPoints(IG);
                    List<Point> IG_max_points = getPoints(IG_max);
                    List<Point> IG_min_points = getPoints(IG_min);

                    return SfCartesianChart(
                      title: ChartTitle(text: 'Interstitial Glucose'),
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(text: 'time (min)'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'IG (mg/dl)'),
                      ),
                      series: <ChartSeries>[
                        LineSeries<Point, int>(
                            dataSource: IG_points,
                            xValueMapper: (Point point, _) => point.time,
                            yValueMapper: (Point point, _) => point.IG),
                        FastLineSeries<Point, int>(
                          dataSource: IG_max_points,
                          dashArray: <double>[5, 5],
                          xValueMapper: (Point point, _) => point.time,
                          yValueMapper: (Point point, _) => point.IG,
                        ),
                        FastLineSeries<Point, int>(
                            dataSource: IG_min_points,
                            dashArray: <double>[5, 5],
                            xValueMapper: (Point point, _) => point.time,
                            yValueMapper: (Point point, _) => point.IG),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class Point {
  Point(this.time, this.IG);

  final int time;
  final double? IG;
}
