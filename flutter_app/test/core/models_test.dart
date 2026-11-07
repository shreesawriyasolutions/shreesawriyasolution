import 'package:flutter_test/flutter_test.dart';
import 'package:sss_shop/core/models/models.dart';
import 'package:sss_shop/core/utils/csv.dart';
import 'package:sss_shop/core/utils/format.dart';

void main() {
  group('format', () {
    test('inr uses Indian grouping', () {
      expect(inr(1234567), '₹12,34,567');
      expect(inr(null), '₹0');
      expect(inr('450.6'), '₹451');
    });

    test('clean / numOrNull', () {
      expect(clean('  '), isNull);
      expect(clean(' a '), 'a');
      expect(numOrNull(''), isNull);
      expect(numOrNull('12'), 12);
    });

    test('shortName strips email domain', () {
      expect(shortName('deepak@shop.in'), 'deepak');
      expect(initials('Ankush Kumar'), 'AK');
    });
  });

  group('Repair', () {
    test('fromMap reads joined customer and computes due', () {
      final r = Repair.fromMap({
        'id': '1',
        'repair_code': 'SSS-0001',
        'status': 'Repair in Progress',
        'device_model': 'Vivo Y20',
        'customers': {'name': 'Rohit', 'mobile': '9812345670'},
        'estimated_charge': 1500,
        'advance_paid': 500,
        'accessories': ['SIM'],
      });
      expect(r.customerName, 'Rohit');
      expect(r.isOpen, isTrue);
      expect(r.due, 1000);
      expect(r.searchText, contains('9812345670'));
    });

    test('closed statuses are not open', () {
      final r = Repair.fromMap({'id': '1', 'status': 'Delivered'});
      expect(r.isOpen, isFalse);
    });
  });

  group('StockItem.state', () {
    StockItem item(int q, int min) => StockItem.fromMap({'id': 'x', 'product_name': 'Battery', 'quantity': q, 'min_quantity': min});
    test('out / low / ok', () {
      expect(item(0, 2).state, StockState.out);
      expect(item(2, 2).state, StockState.low);
      expect(item(5, 2).state, StockState.ok);
      expect(item(1, 0).state, StockState.ok);
    });
  });

  test('Bill.files labels bill and id files', () {
    final b = Bill.fromMap({
      'id': 'b',
      'bill_file_path': 'u/bill-1.jpg',
      'id_file_path': 'u/id-1.jpg',
      'extra_file_paths': ['u/bill-2.pdf', 'u/id-2.jpg'],
    });
    expect(b.files.map((f) => f.$2), ['Bill 1', 'ID 1', 'Bill 2', 'ID 2']);
  });

  test('csv escapes quotes and formula injection', () {
    final csv = buildCsv(['A'], [
      ['=SUM(1)'],
      ['say "hi"'],
    ]);
    expect(csv, contains('"\'=SUM(1)"'));
    expect(csv, contains('"say ""hi"""'));
  });
}
