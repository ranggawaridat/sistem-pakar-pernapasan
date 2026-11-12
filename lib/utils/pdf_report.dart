import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/expert_rules.dart';

/// Generator laporan hasil diagnosis dalam format PDF.
///
/// Laporan memuat: identitas dokumen, hasil diagnosis akhir, dan rincian
/// jawaban kuesioner 19 gejala (Ya/Tidak).
class DiagnosisPdfReport {
  /// Membangun dokumen PDF dan mengembalikan isi file sebagai bytes.
  static Future<Uint8List> build({
    required Map<String, dynamic> diagnosisResult,
    required List<String> selectedSymptoms,
  }) async {
    final yaSet = selectedSymptoms.toSet();
    final now = DateTime.now();
    final tanggal =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final pdf = pw.Document(
      title: 'Hasil Diagnosis Sistem Pakar Pernapasan',
      author: 'Sistem Pakar Pernapasan',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---- Kop dokumen ----
              pw.Text(
                'Sistem Pakar Diagnosis Awal Penyakit Pernapasan Kronis',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0D9488'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Metode: Forward Chaining  |  Waktu Cetak: $tanggal',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Divider(height: 20),

              // ---- Hasil diagnosis ----
              pw.Text(
                'Hasil Diagnosis',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F0FDF4'),
                  border: pw.Border.all(color: PdfColor.fromHex('#0D9488'), width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${diagnosisResult['code']} - ${diagnosisResult['name']}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0F766E'),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      diagnosisResult['description'] ?? '',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey800, lineSpacing: 3),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Saran / Penanganan Medis Awal:',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      diagnosisResult['solution'] ?? '',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey800, lineSpacing: 3),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // ---- Rincian jawaban kuesioner ----
              pw.Text(
                'Rincian Jawaban Kuesioner (19 Gejala)',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              _tabelJawaban(yaSet),

              pw.Spacer(),

              // ---- Disclaimer ----
              pw.Divider(),
              pw.Text(
                'Catatan: Dokumen ini dihasilkan otomatis oleh aplikasi Sistem Pakar '
                'Pernapasan dan bukan merupakan diagnosis medis resmi. '
                'Tetap konsultasikan hasil ini dengan dokter.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Tabel 19 gejala beserta jawaban Ya/Tidak pengguna.
  static pw.Widget _tabelJawaban(Set<String> yaSet) {
    final rows = <List<String>>[];
    var i = 1;
    ExpertSystemEngine.symptoms.forEach((kode, teks) {
      rows.add([
        '$i',
        kode,
        teks,
        yaSet.contains(kode) ? 'Ya' : 'Tidak',
      ]);
      i++;
    });

    return pw.TableHelper.fromTextArray(
      headers: ['No', 'Kode', 'Gejala', 'Jawaban'],
      data: rows,
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FixedColumnWidth(44),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FixedColumnWidth(52),
      },
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0D9488')),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
    );
  }

  /// Membuat PDF lalu langsung membuka dialog cetak/simpan/bagikan.
  static Future<void> share({
    required Map<String, dynamic> diagnosisResult,
    required List<String> selectedSymptoms,
  }) async {
    final bytes = await build(
      diagnosisResult: diagnosisResult,
      selectedSymptoms: selectedSymptoms,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'hasil-diagnosis-pernapasan-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
