// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_firebase_in_app_messaging/otel_firebase_in_app_messaging.dart';

/// Traces Firebase In-App Messaging calls with OpenTelemetry.
///
/// `otel_firebase_in_app_messaging` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Firebase In-App Messaging call in
/// [tracedFirebaseInAppMessaging]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'firebase-in-app-messaging-example');

  // Wraps a Firebase In-App Messaging call in a CLIENT span.
  final firebaseInAppMessagingId = await tracedFirebaseInAppMessaging<String>(
    operation: 'create',
    invoke: () async {
      // Make the Firebase In-App Messaging call here, then report what it returned.
      const id = 'firebase_in_app_messaging_8f3a2c';
      return const FirebaseInAppMessagingCallResult(
          value: id,
          result: FirebaseInAppMessagingResult(
              campaignId: 'campaign_8f3a2c',
              campaignName: 'example',
              messageId: 'message_8f3a2c',
              messageType: 'card',
              triggerEvent: 'order.created',
              actionUrl: 'https://api.example.com/v1/resource',
              dismissType: 'auto',
              deliveryDataCollectionEnabled: false,
              messagesSuppressed: true));
    },
  );
  OTelLog.info(
      'tracedFirebaseInAppMessaging create returned $firebaseInAppMessagingId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutFirebaseInAppMessagingInstrumentationAsync.
  await runWithoutFirebaseInAppMessagingInstrumentationAsync(
    () => tracedFirebaseInAppMessaging<String>(
      operation: 'create',
      invoke: () async {
        const id = 'firebase_in_app_messaging_8f3a2c';
        return const FirebaseInAppMessagingCallResult(
            value: id,
            result: FirebaseInAppMessagingResult(
                campaignId: 'campaign_8f3a2c',
                campaignName: 'example',
                messageId: 'message_8f3a2c',
                messageType: 'card',
                triggerEvent: 'order.created',
                actionUrl: 'https://api.example.com/v1/resource',
                dismissType: 'auto',
                deliveryDataCollectionEnabled: false,
                messagesSuppressed: true));
      },
    ),
  );

  await OTel.shutdown();
}
