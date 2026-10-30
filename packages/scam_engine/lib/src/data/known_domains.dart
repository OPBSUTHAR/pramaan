/// Domains that genuinely belong to the organisation they claim to represent.
///
/// Used for two things: whitelisting (reduces risk) and lookalike detection
/// (raises risk when a host is one edit away from a real one).
abstract final class KnownDomains {
  /// Official registrable domains, lower case, no scheme.
  static const Set<String> official = <String>{
    'sbi.co.in',
    'onlinesbi.sbi',
    'hdfcbank.com',
    'icicibank.com',
    'axisbank.com',
    'kotak.com',
    'pnbindia.in',
    'bankofbaroda.in',
    'unionbankofindia.co.in',
    'canarabank.com',
    'bankofindia.co.in',
    'iob.in',
    'centralbankofindia.co.in',
    'indianbank.in',
    'ucobank.com',
    'rblbank.com',
    'yesbank.in',
    'idfcfirstbank.com',
    'indusind.com',
    'federalbank.co.in',
    'aubank.in',
    'paytm.com',
    'phonepe.com',
    'google.com',
    'amazon.in',
    'flipkart.com',
    'myntra.com',
    'swiggy.com',
    'zomato.com',
    'irctc.co.in',
    'npci.org.in',
    'uidai.gov.in',
    'incometax.gov.in',
    'gst.gov.in',
    'epfindia.gov.in',
    'pmkisan.gov.in',
    'cybercrime.gov.in',
    'india.gov.in',
    'meity.gov.in',
    'rbi.org.in',
    'sebi.gov.in',
    'irdai.gov.in',
    'trai.gov.in',
    'jio.com',
    'airtel.in',
    'vi.in',
    'bsnl.co.in',
    'whatsapp.com',
    'telegram.org',
    'facebook.com',
    'instagram.com',
    'twitter.com',
    'x.com',
    'linkedin.com',
    'github.com',
    'microsoft.com',
    'apple.com',
  };

  /// Brand labels (the part before the TLD) that scammers typosquat most.
  static const Set<String> brandLabels = <String>{
    'sbi', 'hdfcbank', 'hdfc', 'icicibank', 'icici', 'axisbank', 'kotak',
    'paytm', 'phonepe', 'googlepay', 'amazon', 'flipkart', 'irctc',
    'npci', 'uidai', 'incometax', 'gst', 'epfindia', 'pmkisan',
    'cybercrime', 'rbi', 'jio', 'airtel', 'whatsapp', 'telegram',
    'myntra', 'swiggy', 'zomato',
  };

  /// Free / throwaway TLDs that legitimate Indian institutions never use.
  static const Set<String> disposableTlds = <String>{
    'tk', 'ml', 'ga', 'cf', 'gq', 'xyz', 'top', 'click', 'link', 'icu',
    'buzz', 'rest', 'fit', 'work', 'zip', 'mov', 'su', 'cc', 'bid', 'win',
    'download', 'stream', 'review', 'country', 'kim', 'party', 'gdn', 'loan',
  };

  /// URL shorteners, which hide the real destination.
  static const Set<String> shorteners = <String>{
    'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly', 'is.gd', 'buff.ly',
    'cutt.ly', 'rb.gy', 'rebrand.ly', 'shorturl.at', 'tiny.cc', 'lnkd.in',
    's.id', 'clck.ru', 'v.gd', 't.ly', 'shorte.st', 'adf.ly', 'bl.ink',
    'urlz.fr', '1url.com', 'short.gy', 'tr.ee', 'trib.al', 'soo.gd',
    'surl.li', 'shrtco.de', 'tiny.one', 'clk.sh', 'u.to', 'x.co',
  };
}
