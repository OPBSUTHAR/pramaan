/// UPI handles issued by NPCI-registered PSPs.
///
/// A UPI address is `username@handle`. The handle identifies the bank or wallet
/// that holds the account — it is *not* chosen by the user. So a handle that is
/// not on this list is either a brand-new PSP we have not seen yet, or a fake.
/// Either way it is worth a warning.
abstract final class PspRegistry {
  /// Handles in active use by regulated PSPs (banks + wallets + TPAPs).
  static const Set<String> handles = <String>{
    // HDFC Bank
    'okhdfcbank', 'hdfcbank', 'hdfcbankltd', 'hdfc',
    // ICICI Bank
    'okicici', 'icici', 'ibl', 'icicibank',
    // Axis Bank
    'okaxis', 'axl', 'axisbank', 'axisb',
    // State Bank of India
    'oksbi', 'sbi', 'sbibank', 'onlinesbi',
    // PhonePe
    'ybl', 'phonepe',
    // Paytm Payments Bank
    'paytm', 'ptyes', 'ptaxis', 'ptsbi', 'pthdfc', 'paytmbank',
    // Amazon Pay
    'apl', 'amazonpay',
    // Airtel Payments Bank
    'airtel', 'airtelpaymentsbank',
    // Google Pay / BHIM
    'upi', 'bhim', 'googlepay',
    // Kotak Mahindra Bank
    'kmbl', 'kotak', 'kotakbank',
    // Yes Bank
    'yesg', 'yesbank', 'yesb',
    // IDFC First Bank
    'idfcbank', 'idfcfirstbank', 'idfc',
    // IndusInd Bank
    'indus', 'indusind',
    // Federal Bank
    'federal', 'fbl', 'fedbank',
    // Bank of Baroda
    'barodampay', 'bob', 'baroda',
    // Punjab National Bank
    'pnb', 'pnbnet',
    // Union Bank of India
    'unionbank', 'uboi',
    // Canara Bank
    'cnrb', 'canara',
    // Bank of India
    'boi',
    // Indian Overseas Bank
    'iob',
    // Central Bank of India
    'cbin',
    // Allahabad / Indian Bank
    'allbank', 'indianbank',
    // UCO Bank
    'uco',
    // RBL Bank
    'rbl', 'rblbank',
    // DBS Bank India
    'dbs',
    // AU Small Finance Bank
    'au', 'aubank', 'ausfb',
    // Fincare / AU
    'fincare',
    // Jana Small Finance Bank
    'jana', 'janabank',
    // Equitas
    'equitas',
    // Ujjivan
    'ujjivan',
    // Suryoday
    'suryoday',
    // ESAF
    'esaf',
    // Utkarsh
    'utkarsh',
    // Capital Small Finance Bank
    'capital',
    // North East SFB
    'nesfb',
    // Shivalik
    'shivalik',
    // Slice / SBM
    'slice', 'sbm',
    // Jupiter (Axis)
    'jupiteraxis',
    // Fi Money (Federal)
    'fi', 'fifederal',
    // Navi (Axis)
    'naviaxis',
    // CRED (Axis/ICICI)
    'cred', 'credaxis',
    // Freecharge
    'freecharge', 'freechargepaymentsbank',
    // Jio Payments Bank
    'jio', 'jiopaymentsbank',
    // Fino Payments Bank
    'fino', 'finobank',
    // India Post Payments Bank
    'ippb', 'postbank',
    // NSDL Payments Bank
    'nsdl',
    // Aditya Birla Payments Bank
    'abpb',
    // WhatsApp Pay (ICICI)
    'waicici', 'wahdfcbank', 'waaxis', 'wasbi',
    // Super.money (Utkarsh)
    'superyes', 'super',
    // Time Cosmos
    'timecosmos',
    // Mswipe / merchant handles
    'mswipe',
    // Razorpay / Cashfree merchant VPAs
    'razorpay', 'cashfree',
    // Mobikwik
    'mobikwik', 'zaakpay',
    // Bhartiya
    'yesbankltd',
    // ICICI Prudential style corporate
    'icicipru',
    // Nainital Bank
    'nainital',
    // SBM Bank
    'sbmbank',
  };

  /// True when [handle] is issued by a known regulated PSP.
  static bool isKnown(String handle) => handles.contains(handle.toLowerCase());

  /// Known handles that look similar to [handle], best match first.
  ///
  /// Used to catch typosquats like `okhdfcbnak` or `paytmm`.
  static List<String> lookalikes(String handle, {int maxDistance = 2}) {
    final String needle = handle.toLowerCase();
    if (handles.contains(needle)) return const <String>[];
    if (needle.length < 3) return const <String>[];

    final List<String> hits = <String>[];
    for (final String known in handles) {
      if ((known.length - needle.length).abs() > maxDistance) continue;
      if (_withinDistance(needle, known, maxDistance)) hits.add(known);
    }
    return hits;
  }

  static bool _withinDistance(String a, String b, int max) {
    // Cheap bail-out: identical prefix length check happens inside the DP, but
    // skipping obviously-different strings keeps the scan fast on long inputs.
    if (a == b) return true;
    final int lenDiff = (a.length - b.length).abs();
    if (lenDiff > max) return false;
    return _boundedLevenshtein(a, b, max) <= max;
  }

  static int _boundedLevenshtein(String a, String b, int bound) {
    final List<int> prev = List<int>.generate(b.length + 1, (int i) => i);
    final List<int> curr = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      int rowMin = curr[0];
      for (int j = 1; j <= b.length; j++) {
        final int cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final int del = prev[j] + 1;
        final int ins = curr[j - 1] + 1;
        final int sub = prev[j - 1] + cost;
        int best = del < ins ? del : ins;
        if (sub < best) best = sub;
        curr[j] = best;
        if (best < rowMin) rowMin = best;
      }
      if (rowMin > bound) return bound + 1;
      for (int j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[b.length];
  }
}
