import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'dashboard_card.dart';

/// Chart section (spec item 11): four panels side-by-side per the reference
/// layout — Employment Status, Length of Service, Job Level, Gender Diversity.
class ChartSection extends StatelessWidget {
  const ChartSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const panels = [
          EmploymentStatusPanel(),
          LengthOfServicePanel(),
          JobLevelPanel(),
          GenderDiversityPanel(),
        ];
        if (constraints.maxWidth > 1150) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in panels) Expanded(child: p),
              ].expand((w) sync* {
                yield w;
                yield const SizedBox(width: 12);
              }).toList()
                ..removeLast(),
            ),
          );
        }
        if (constraints.maxWidth > 720) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: panels,
          );
        }
        return Column(
          children: [
            for (final p in panels) ...[p, const SizedBox(height: 12)],
          ],
        );
      },
    );
  }
}

const List<Color> _palette = [
  kPrimaryColor,
  Color(0xFFEF6C00),
  Color(0xFF7B1FA2),
  Color(0xFFC62828),
  Color(0xFF00838F),
  Color(0xFF2E7D32),
  kPrimaryLightColor,
];

/// Shared panel shell: title + overflow menu, body, Filter footer.
class _ChartPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onRefresh;

  const _ChartPanel({
    required this.title,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(child: TitleTextView(title, textSize: 14)),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) {
                    if (value == "refresh") onRefresh();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: "refresh", child: Text("Refresh data")),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: child),
          const Divider(height: 1),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "all") onRefresh();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "all", child: Text("All employees")),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filter",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (count / total) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          Text("$count",
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text("${pct.toStringAsFixed(1)}%",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}

/// Horizontal 100% stacked bar + total + legend.
class _StackedBarWithLegend extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _StackedBarWithLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    final total =
        data.fold<int>(0, (sum, row) => sum + (row["count"] as int? ?? 0));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  for (int i = 0; i < data.length; i++)
                    Expanded(
                      flex: (data[i]["count"] as int? ?? 0) == 0
                          ? 0
                          : (data[i]["count"] as int? ?? 0),
                      child: Container(
                        height: 10,
                        color: _palette[i % _palette.length],
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text("0%",
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const Spacer(),
                Text("100%",
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Row(
            children: [
              TitleTextView("Total",
                  textSize: 12,
                  fontFamily: Fonts.gilroy_semibold,
                  textColor: Colors.grey),
              const Spacer(),
              TitleTextView("$total",
                  textSize: 12, fontFamily: Fonts.gilroy_semibold),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              children: [
                for (int i = 0; i < data.length; i++)
                  _LegendRow(
                    color: _palette[i % _palette.length],
                    label: (data[i]["label"] ?? "").toString(),
                    count: (data[i]["count"] as int? ?? 0),
                    total: total,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmploymentStatusPanel extends StatelessWidget {
  const EmploymentStatusPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final data = viewModel.chartFor("employment_status");
    return _ChartPanel(
      title: "Employment Status",
      onRefresh: viewModel.refreshCharts,
      child: viewModel.chartLoading && data.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : data.isEmpty
              ? const EmptyBody()
              : _StackedBarWithLegend(data: data),
    );
  }
}

class JobLevelPanel extends StatelessWidget {
  const JobLevelPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final data = viewModel.chartFor("job_level");
    return _ChartPanel(
      title: "Job Level",
      onRefresh: viewModel.refreshCharts,
      child: viewModel.chartLoading && data.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : data.isEmpty
              ? const EmptyBody()
              : _StackedBarWithLegend(data: data),
    );
  }
}

String _shortTenure(String label) {
  switch (label) {
    case "< 1 year":
      return "< 1 yr";
    case "1-3 years":
      return "1-3 yr";
    case "3-5 years":
      return "3-5 yr";
    case "5-10 years":
      return "5-10 yr";
    case "> 10 years":
      return "10+ yr";
    default:
      return "?";
  }
}

class LengthOfServicePanel extends StatelessWidget {
  const LengthOfServicePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final data = viewModel.chartFor("length_of_service");
    final maxCount = data.fold<int>(
        0, (m, row) => (row["count"] as int? ?? 0) > m ? (row["count"] as int) : m);
    return _ChartPanel(
      title: "Length of Service",
      onRefresh: viewModel.refreshCharts,
      child: viewModel.chartLoading && data.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : data.isEmpty
              ? const EmptyBody()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
                  child: BarChart(
                    BarChartData(
                      maxY: (maxCount * 1.2).clamp(4, double.infinity).toDouble(),
                      minY: 0,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval:
                            (maxCount / 3).clamp(1, double.infinity).toDouble(),
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: (maxCount / 3)
                                .clamp(1, double.infinity)
                                .toDouble(),
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= data.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 6),
                                child: Text(
                                  _shortTenure(
                                      (data[i]["label"] ?? "").toString()),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < data.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: ((data[i]["count"] as int? ?? 0))
                                    .toDouble(),
                                color: kPrimaryColor,
                                width: 34,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class GenderDiversityPanel extends StatelessWidget {
  const GenderDiversityPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final data = viewModel.chartFor("gender_diversity");
    final total =
        data.fold<int>(0, (sum, row) => sum + (row["count"] as int? ?? 0));
    return _ChartPanel(
      title: "Gender Diversity",
      onRefresh: viewModel.refreshCharts,
      child: viewModel.chartLoading && data.isEmpty
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : data.isEmpty
              ? const EmptyBody()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 42,
                                startDegreeOffset: -90,
                                sections: [
                                  for (int i = 0; i < data.length; i++)
                                    PieChartSectionData(
                                      value: (data[i]["count"] as num? ?? 0)
                                          .toDouble(),
                                      color:
                                          _palette[i % _palette.length],
                                      showTitle: false,
                                    ),
                                ],
                              ),
                            ),
                            Text("$total",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          children: [
                            for (int i = 0; i < data.length; i++)
                              _LegendRow(
                                color: _palette[i % _palette.length],
                                label: (data[i]["label"] ?? "").toString(),
                                count: (data[i]["count"] as int? ?? 0),
                                total: total,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
