/// Shree Sawriya Solutions: wahi Supabase project jo website ka shop app
/// (app.html, sale.html, bills.html, stock.html) use karta hai.
class AppConfig {
  AppConfig._();

  static const supabaseUrl = 'https://bwldelmfkcynfvbqcneb.supabase.co';
  static const supabaseKey = 'sb_publishable_GKmljKQOjWzJ54FdZVPk_g_auEFS9VG';
  static const billsBucket = 'bills';
  static const site = 'https://shreesawriyasolutions.in';
}

class RepairStatus {
  const RepairStatus(this.key, this.label, this.tone);
  final String key;
  final String label;
  final Tone tone;
}

/// Pill / badge colour families.
enum Tone { blue, violet, amber, gold, green, red, muted }

const repairStatuses = <RepairStatus>[
  RepairStatus('Received', 'Received', Tone.blue),
  RepairStatus('Diagnosing', 'Diagnosing', Tone.violet),
  RepairStatus('Repair in Progress', 'Repair chalu', Tone.amber),
  RepairStatus('Waiting for Part', 'Part ka wait', Tone.gold),
  RepairStatus('Ready for Pickup', 'Ready', Tone.green),
  RepairStatus('Delivered', 'Delivered', Tone.muted),
  RepairStatus('Returned', 'Wapas (bina repair)', Tone.red),
];

const repairFlow = ['Received', 'Repair in Progress', 'Ready for Pickup', 'Delivered'];
const closedStatuses = ['Delivered', 'Returned'];

RepairStatus statusOf(String key) => repairStatuses.firstWhere(
      (s) => s.key == key,
      orElse: () => RepairStatus(key, key, Tone.muted),
    );

const accessories = ['SIM', 'Memory Card', 'Back Cover', 'Charger', 'Cable', 'Box', 'Earphone'];
const conditions = [
  'Phone ON hota hai',
  'Phone dead',
  'Screen tooti',
  'Back tooti',
  'Pani laga',
  'Body dent/scratch',
  'Touch theek',
  'Camera theek',
  'Speaker/Mic theek',
  'Charging theek',
  'Face ID/Fingerprint theek',
];
const payModes = ['Cash', 'UPI', 'Card', 'Other'];

class BillType {
  const BillType(this.value, this.label, this.tone);
  final String value;
  final String label;
  final Tone tone;
}

const billTypes = <BillType>[
  BillType('Purchase Bill', 'Purchase (Kharid)', Tone.blue),
  BillType('Sale Bill', 'Sale (Bikri)', Tone.green),
  BillType('Unlocking Job', 'Unlocking', Tone.violet),
];

BillType billTypeOf(String v) =>
    billTypes.firstWhere((t) => t.value == v, orElse: () => billTypes.first);

const workTypes = ['Software', 'FRP Unlock', 'Screen Lock / Pattern', 'iCloud', 'Network Unlock', 'Other'];
const stockCategories = ['Spare Part', 'Accessory', 'Mobile', 'Other'];
const stockReasons = ['Purchase', 'Used in repair', 'Sale', 'Adjust', 'Return'];
