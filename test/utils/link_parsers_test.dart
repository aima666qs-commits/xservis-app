import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/utils/link_parsers.dart';

void main() {
  group('XFreedom deep links', () {
    test('registers xfreedom as a supported protocol', () {
      expect(LinkParser.protocols.first, 'xfreedom');
      expect(LinkParser.protocols, contains('hiddify'));
    });

    test('parses signed subscription URL from xfreedom import link', () {
      const subscription = 'https://xservis.app/sub/xray?token=abc123';
      final encoded = Uri.encodeQueryComponent(subscription);
      final parsed = LinkParser.deep(
        'xfreedom://import?url=$encoded&name=XFreedom',
      );

      expect(parsed, isNotNull);
      expect(parsed!.url, subscription);
      expect(parsed.name, 'XFreedom');
    });

    test('keeps legacy hiddify import links compatible', () {
      const subscription = 'https://example.com/sub';
      final encoded = Uri.encodeQueryComponent(subscription);
      final parsed = LinkParser.deep('hiddify://import?url=$encoded');

      expect(parsed, isNotNull);
      expect(parsed!.url, subscription);
    });
  });
}
