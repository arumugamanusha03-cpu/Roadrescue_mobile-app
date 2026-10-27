import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../tracking/rescue_format.dart';
import '../invoice_data.dart';

/// Builds the invoice PDF. Uses the bundled Inter font (the PDF default
/// font has no ₹ glyph) and prints a DEMO banner while data is sample.
Future<Uint8List> buildInvoicePdf(
  InvoiceData d, {
  pw.Font? base,
  pw.Font? bold,
}) async {
  base ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
  bold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));

  const navy = PdfColor.fromInt(0xFF0B1B33);
  const blue = PdfColor.fromInt(0xFF1A5FE8);
  const grey = PdfColor.fromInt(0xFF6B7C91);
  const line = PdfColor.fromInt(0xFFDCE4EE);
  const warn = PdfColor.fromInt(0xFFC98A12);

  final doc = pw.Document(
    title: 'RoadRescue invoice #${d.requestId}',
    author: 'RoadRescue',
    theme: pw.ThemeData.withFont(base: base, bold: bold),
  );

  pw.Widget row(String label, String value, {bool strong = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  color: strong ? navy : grey,
                  fontSize: strong ? 13 : 11,
                ),
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: strong ? blue : navy,
                fontSize: strong ? 16 : 11,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  pw.Widget field(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: grey, fontSize: 9)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: const pw.TextStyle(color: navy, fontSize: 11)),
      ],
    ),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (d.isDemo)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: warn, width: 1.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'DEMO INVOICE — generated from sample data. Not a tax '
                'invoice and no payment was processed.',
                style: pw.TextStyle(
                  color: warn,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Road',
                            style: pw.TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.TextSpan(
                            text: 'Rescue',
                            style: pw.TextStyle(
                              color: blue,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      'Roadside assistance',
                      style: const pw.TextStyle(color: grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      color: navy,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '#${d.requestId}',
                    style: const pw.TextStyle(color: grey, fontSize: 10),
                  ),
                  pw.Text(
                    RescueFormat.dateTimePadded(d.issuedAt),
                    style: const pw.TextStyle(color: grey, fontSize: 10),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    d.paid ? 'PAID (DEMO)' : 'UNPAID',
                    style: pw.TextStyle(
                      color: d.paid ? blue : warn,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Divider(color: line),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (d.customerName != null)
                      field('Billed to', d.customerName!),
                    field('Service', d.service.label),
                    field('Vehicle', d.vehicle.isEmpty ? '—' : d.vehicle),
                  ],
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    field('Provider', d.providerName ?? '—'),
                    if (d.providerVehicle != null)
                      field('Provider vehicle', d.providerVehicle!),
                    field('Location', d.address),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF3F6FB),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                row('Service charge', RescueFormat.rupees(d.serviceCharge)),
                row('Convenience fee', RescueFormat.rupees(d.convenienceFee)),
                pw.Divider(color: line),
                row('Total amount', RescueFormat.rupees(d.total), strong: true),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'Thank you for choosing RoadRescue.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(color: grey, fontSize: 10),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
