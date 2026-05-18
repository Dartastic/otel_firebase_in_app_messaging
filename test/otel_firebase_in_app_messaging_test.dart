// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_firebase_in_app_messaging/otel_firebase_in_app_messaging.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_firebase_in_app_messaging-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('dispatchClick records campaign + message type', () async {
    await tracedFirebaseInAppMessaging<String>(
      operation: 'dispatchClick',
      invoke: () async => const FirebaseInAppMessagingCallResult(
        value: 'ok',
        result: FirebaseInAppMessagingResult(
          campaignId: 'camp_1',
          campaignName: 'spring_sale',
          messageId: 'm_1',
          messageType: 'modal',
          actionUrl: 'https://example.com/sale',
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('firebase_in_app_messaging dispatchClick')!,
    );
    expect(a['firebase_in_app_messaging.campaign.name'], 'spring_sale');
    expect(a['firebase_in_app_messaging.message.type'], 'modal');
  });

  test('render error sets span error', () async {
    await tracedFirebaseInAppMessaging<String>(
      operation: 'dispatchRenderError',
      invoke: () async => const FirebaseInAppMessagingCallResult(
        value: 'ok',
        result: FirebaseInAppMessagingResult(campaignId: 'camp_1'),
      ),
    );
    expect(
      spans
          .findSpanByName('firebase_in_app_messaging dispatchRenderError')!
          .status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutFirebaseInAppMessagingInstrumentationAsync(() async {
      await tracedFirebaseInAppMessaging<String>(
        operation: 'triggerEvent',
        invoke: () async => const FirebaseInAppMessagingCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('firebase_in_app_messaging '), isEmpty);
  });
}
