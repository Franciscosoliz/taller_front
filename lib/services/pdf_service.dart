import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';

class PdfService {
  static Future<void> generateInvoice({
    required String cliente,
    required String placa,
    required String mecanico,
    required List<dynamic> detalles,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            // CORRECCIÓN: Se usa crossAxisAlignment en lugar de crossSize
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ENCABEZADO INDUSTRIAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TALLER MECANICO V8",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber,
                    ),
                  ),
                  pw.Text(
                    "REPORTE DE SERVICIO",
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.amber),
              pw.SizedBox(height: 20),

              // DATOS DEL CLIENTE Y VEHÍCULO
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                // CORRECCIÓN: Se eliminó crossSize (no existe en Container)
                width: double
                    .infinity, // Esto hace que el gris ocupe todo el ancho
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "CLIENTE: $cliente",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text("VEHÍCULO (PLACA): $placa"),
                    pw.Text("MECÁNICO: $mecanico"),
                    pw.Text(
                      "FECHA: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // TABLA DE SERVICIOS
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey900,
                ),
                headers: ['Servicio', 'Cant.', 'Precio U.', 'Subtotal'],
                data: detalles
                    .map(
                      (d) => [
                        d['servicio_nombre'],
                        d['cantidad'].toString(),
                        "\$${d['precio_unitario']}",
                        "\$${d['subtotal']}",
                      ],
                    )
                    .toList(),
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "GRACIAS POR SU CONFIANZA",
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, // <--- FORMA CORRECTA
                    color: PdfColors.grey700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // GUARDAR Y ABRIR
    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/reporte_$placa.pdf");
      await file.writeAsBytes(await pdf.save());

      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint("Error al generar o abrir el PDF: $e");
    }
  }
}
