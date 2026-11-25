import 'dart:io';

/// Data satu mata kuliah.
typedef MataKuliah = ({String nama, int sks, String nilai});

// Batas SKS yang diterima.
const int sksMin = 1;
const int sksMaks = 6;

// Bobot nilai dalam huruf
const Map<String, int> bobotNilai = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'E': 0};

/// Mengubah nilai huruf menjadi bobot.
int bobot(String huruf) {
  final int? nilai = bobotNilai[huruf]; // null jika huruf tidak dikenal
  if (nilai == null) {
    throw FormatException('Nilai "$huruf" tidak dikenal.');
  }
  return nilai;
}

/// Periksa SKS. Melempar [FormatException] jika bukan angka 1-6.
int validasiSks(String teks) {
  final int? sks = int.tryParse(teks.trim());
  if (sks == null || sks < sksMin || sks > sksMaks) {
    throw FormatException(
      'SKS harus berupa angka $sksMin-$sksMaks, bukan "$teks".',
    );
  }
  return sks;
}

/// Periksa nilai huruf. Melempar [FormatException] jika bukan A-E.
String validasiNilai(String teks) {
  final String huruf = teks.trim().toUpperCase();
  if (!bobotNilai.containsKey(huruf)) {
    throw FormatException(
      'Nilai harus ${bobotNilai.keys.join(', ')}, bukan "$teks".',
    );
  }
  return huruf;
}

/// Menampilkan [label], lalu membaca satu baris input.
String bacaBaris(String label) {
  stdout.write(label);
  return (stdin.readLineSync() ?? '').trim(); // String? -> ganti ''
}

void main() {
  final List<MataKuliah> data = [];

  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.');
  while (true) {
    final String nama = bacaBaris('Nama MK : ');
    if (nama.isEmpty) break;

    try {
      final int sks = validasiSks(bacaBaris('SKS     : '));
      final String nilai = validasiNilai(bacaBaris('Nilai   : '));
      data.add((nama: nama, sks: sks, nilai: nilai));
    } on FormatException catch (e) {
      // Data salah diabaikan, program tetap berjalan.
      print('Data diabaikan: ${e.message}');
    }
  }

  print('Data tersimpan: ${data.length} mata kuliah');
}
