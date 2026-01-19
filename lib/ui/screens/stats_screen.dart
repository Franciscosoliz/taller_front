import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/metal_background.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TELEMETRÍA DE RENDIMIENTO", 
          style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: MetalBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildChartSection(),
              const SizedBox(height: 30),
              _buildStatCard("PRODUCTIVIDAD SEMANAL", "94%", Icons.speed, Colors.greenAccent),
              _buildStatCard("REPUESTOS EN STOCK", "128", Icons.inventory, Colors.amberAccent),
              _buildStatCard("ÓRDENES PENDIENTES", "12", Icons.assignment_late, Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("FLUJO DE VEHÍCULOS (7 DÍAS)", 
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                        return Text(days[value.toInt()], 
                          style: const TextStyle(color: Colors.white54, fontSize: 10));
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _makeGroupData(0, 5),
                  _makeGroupData(1, 8),
                  _makeGroupData(2, 3),
                  _makeGroupData(3, 10),
                  _makeGroupData(4, 7),
                  _makeGroupData(5, 4),
                  _makeGroupData(6, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.orangeAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 12,
            color: Colors.white.withValues(alpha:0.05),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withValues(alpha:0.2)),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha:0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Text(value, style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}