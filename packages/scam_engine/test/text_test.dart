import 'package:scam_engine/scam_engine.dart';
import 'package:test/test.dart';

void main() {
  group('levenshtein', () {
    test('classic cases', () {
      expect(levenshtein('kitten', 'sitting'), 3);
      expect(levenshtein('', 'abc'), 3);
      expect(levenshtein('abc', 'abc'), 0);
      expect(levenshtein('okhdfcbank', 'okhdfcbank'), 0);
    });
  });

  group('trigrams', () {
    test('pads with sentinels so short strings still compare', () {
      expect(trigrams('ab'), isNotEmpty);
    });

    test('identical strings are fully similar', () {
      expect(trigramJaccard('hello world', 'hello world'), 1.0);
    });

    test('unrelated strings are barely similar', () {
      expect(trigramJaccard('your account is blocked', 'buy one get one free'),
          lessThan(0.25));
    });

    test('reworded scams stay close', () {
      final double score = trigramJaccard(
        'your kyc is pending update now or account will be blocked',
        'kyc pending please update immediately else your account will be blocked',
      );
      expect(score, greaterThan(0.5));
    });
  });

  group('blended similarity', () {
    test('identical is 1.0', () {
      expect(blendedSimilarity('abc def', 'abc def'), 1.0);
    });

    test('is symmetric', () {
      const String a = 'your account will be blocked today';
      const String b = 'today your account gets blocked';
      expect(
        blendedSimilarity(a, b),
        closeTo(blendedSimilarity(b, a), 1e-9),
      );
    });

    test('a paraphrased scam beats an unrelated one', () {
      const String template =
          'dear customer your kyc is pending your account will be blocked '
          'update immediately';
      const String paraphrase =
          'sir kyc pending hai aapka account block ho jayega turant update karo';
      const String unrelated = 'your pizza is on the way enjoy your meal';

      expect(
        blendedSimilarity(template, paraphrase),
        greaterThan(blendedSimilarity(template, unrelated)),
      );
    });
  });

  group('handle similarity', () {
    test('catches a single character swap', () {
      expect(handleSimilarity('0khdfcbank', 'okhdfcbank'), greaterThan(0.85));
    });
  });

  group('normalizer', () {
    test('lowercases and folds homoglyphs', () {
      // Cyrillic 'а' should become Latin 'a'.
      expect(TextNormalizer.canonical('РАYTM'), contains('paytm'));
    });

    test('appends English tokens for Hindi words', () {
      final String out = TextNormalizer.canonical('आपका खाता बंद हो जाएगा');
      expect(out, contains('account'));
      expect(out, contains('block'));
    });

    test('detects Devanagari', () {
      expect(TextNormalizer.hasDevanagari('नमस्ते'), isTrue);
      expect(TextNormalizer.hasDevanagari('hello'), isFalse);
    });

    test('extracts links, VPAs and amounts', () {
      const String text =
          'Pay Rs 2,500 to rahul@okhdfcbank or visit http://bit.ly/abc';
      expect(TextNormalizer.links(text), isNotEmpty);
      expect(TextNormalizer.upiAddresses(text), contains('rahul@okhdfcbank'));
      expect(TextNormalizer.amounts(text), isNotEmpty);
    });

    test('counts shouting and emoji', () {
      expect(TextNormalizer.capsRatio('THIS IS URGENT'), greaterThan(0.8));
      expect(TextNormalizer.emojiCount('win 🎉🎉 now'), 2);
      expect(TextNormalizer.exclamationCount('act now!!!'), 3);
    });
  });

  group('ScanContext', () {
    test('exposes derived facts', () {
      final ScanContext ctx = ScanContext(
        'Dear customer, KYC pending. Pay Rs 499 to shop@okhdfcbank NOW!',
      );
      expect(ctx.has('kyc'), isTrue);
      expect(ctx.hasAny(<String>['otp', 'pin', 'kyc']), isTrue);
      expect(ctx.wordCount, greaterThan(5));
      expect(ctx.largestAmount, 499);
      expect(ctx.isEmpty, isFalse);
    });

    test('empty context is detected', () {
      expect(ScanContext('   ').isEmpty, isTrue);
    });
  });
}
