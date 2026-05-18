// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_firebase_in_app_messaging_suppression.dart';

const _tracerName = 'dartastic_otel_libs_firebase_in_app_messaging';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class FirebaseInAppMessagingResult {
  const FirebaseInAppMessagingResult({
    this.campaignId,
    this.campaignName,
    this.messageId,
    this.messageType,
    this.triggerEvent,
    this.actionUrl,
    this.dismissType,
    this.deliveryDataCollectionEnabled,
    this.messagesSuppressed,
  });

  final String? campaignId;
  final String? campaignName;
  final String? messageId;

  /// `card`, `modal`, `banner`, `image_only`.
  final String? messageType;

  /// Analytics event or programmatic trigger that fired the message.
  final String? triggerEvent;

  final String? actionUrl;

  /// `auto`, `click`, `swipe`, `unknown`.
  final String? dismissType;

  final bool? deliveryDataCollectionEnabled;
  final bool? messagesSuppressed;
}

class FirebaseInAppMessagingCallResult<T> {
  const FirebaseInAppMessagingCallResult({required this.value, this.result});
  final T value;
  final FirebaseInAppMessagingResult? result;
}

/// Wraps a Firebase In-App Messaging call in a CLIENT span. [operation] is
/// one of `triggerEvent`, `setAutomaticDataCollectionEnabled`,
/// `setMessagesSuppressed`, `dispatchImpression`, `dispatchClick`,
/// `dispatchDismiss`, `dispatchImageLoadError`, `dispatchRenderError`.
Future<T> tracedFirebaseInAppMessaging<T>({
  required String operation,
  required Future<FirebaseInAppMessagingCallResult<T>> Function() invoke,
}) async {
  if (firebaseInAppMessagingInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'firebase_in_app_messaging',
    'rpc.method': operation,
    'firebase_in_app_messaging.operation': operation,
  };

  final span = _tracer().startSpan(
    'firebase_in_app_messaging $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.campaignId != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.campaign.id',
          res.campaignId!,
        ));
      }
      if (res.campaignName != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.campaign.name',
          res.campaignName!,
        ));
      }
      if (res.messageId != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.message.id',
          res.messageId!,
        ));
      }
      if (res.messageType != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.message.type',
          res.messageType!,
        ));
      }
      if (res.triggerEvent != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.trigger.event',
          res.triggerEvent!,
        ));
      }
      if (res.actionUrl != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.action.url',
          res.actionUrl!,
        ));
      }
      if (res.dismissType != null) {
        extras.add(OTel.attributeString(
          'firebase_in_app_messaging.dismiss.type',
          res.dismissType!,
        ));
      }
      if (res.deliveryDataCollectionEnabled != null) {
        extras.add(OTel.attributeBool(
          'firebase_in_app_messaging.delivery.collection_enabled',
          res.deliveryDataCollectionEnabled!,
        ));
      }
      if (res.messagesSuppressed != null) {
        extras.add(OTel.attributeBool(
          'firebase_in_app_messaging.messages.suppressed',
          res.messagesSuppressed!,
        ));
      }
      if (operation == 'dispatchImageLoadError' ||
          operation == 'dispatchRenderError') {
        span.setStatus(
          SpanStatusCode.Error,
          'Firebase In-App Messaging $operation',
        );
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
