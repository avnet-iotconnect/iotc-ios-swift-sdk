#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef IOTCONNECT_SWIFT_H
#define IOTCONNECT_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import Foundation;
@import ObjectiveC;
@import Security;
#endif

#import <IoTConnect/IoTConnect.h>

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="IoTConnect",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)

/// MQTT Client
/// note:
/// MGCDAsyncSocket need delegate to extend NSObject
SWIFT_CLASS("_TtC10IoTConnect9CocoaMQTT")
@interface CocoaMQTT : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end






/// MQTT Client
/// note:
/// MGCDAsyncSocket need delegate to extend NSObject
SWIFT_CLASS("_TtC10IoTConnect10CocoaMQTT5")
@interface CocoaMQTT5 : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end





enum CocoaMQTTCONNACKReasonCode : uint8_t;
@class MqttDecodeConnAck;
@class CocoaMQTT5Message;
@class MqttDecodePubAck;
@class MqttDecodePubRec;
@class MqttDecodePublish;
@class NSDictionary;
@class NSString;
@class MqttDecodeSubAck;
@class MqttDecodeUnsubAck;
enum CocoaMQTTDISCONNECTReasonCode : uint8_t;
enum CocoaMQTTAUTHReasonCode : uint8_t;
@class NSURLAuthenticationChallenge;
@class NSURLCredential;
@class MqttDecodePubComp;
enum CocoaMQTTConnState : uint8_t;

/// CocoaMQTT5 Delegate
SWIFT_PROTOCOL("_TtP10IoTConnect18CocoaMQTT5Delegate_")
@protocol CocoaMQTT5Delegate
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didConnectAck:(enum CocoaMQTTCONNACKReasonCode)ack connAckData:(MqttDecodeConnAck * _Nullable)connAckData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didPublishMessage:(CocoaMQTT5Message * _Nonnull)message id:(uint16_t)id;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didPublishAck:(uint16_t)id pubAckData:(MqttDecodePubAck * _Nullable)pubAckData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didPublishRec:(uint16_t)id pubRecData:(MqttDecodePubRec * _Nullable)pubRecData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didReceiveMessage:(CocoaMQTT5Message * _Nonnull)message id:(uint16_t)id publishData:(MqttDecodePublish * _Nullable)publishData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didSubscribeTopics:(NSDictionary * _Nonnull)success failed:(NSArray<NSString *> * _Nonnull)failed subAckData:(MqttDecodeSubAck * _Nullable)subAckData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didUnsubscribeTopics:(NSArray<NSString *> * _Nonnull)topics unsubAckData:(MqttDecodeUnsubAck * _Nullable)unsubAckData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didReceiveDisconnectReasonCode:(enum CocoaMQTTDISCONNECTReasonCode)reasonCode;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didReceiveAuthReasonCode:(enum CocoaMQTTAUTHReasonCode)reasonCode;
///
- (void)mqtt5DidPing:(CocoaMQTT5 * _Nonnull)mqtt5;
///
- (void)mqtt5DidReceivePong:(CocoaMQTT5 * _Nonnull)mqtt5;
///
- (void)mqtt5DidDisconnect:(CocoaMQTT5 * _Nonnull)mqtt5 withError:(NSError * _Nullable)err;
@optional
/// Manually validate SSL/TLS server certificate.
/// This method will be called if enable  <code>allowUntrustCACertificate</code>
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didReceive:(SecTrustRef _Nonnull)trust completionHandler:(void (^ _Nonnull)(BOOL))completionHandler;
- (void)mqtt5UrlSession:(CocoaMQTT5 * _Nonnull)mqtt didReceiveTrust:(SecTrustRef _Nonnull)trust didReceiveChallenge:(NSURLAuthenticationChallenge * _Nonnull)challenge completionHandler:(void (^ _Nonnull)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didPublishComplete:(uint16_t)id pubCompData:(MqttDecodePubComp * _Nullable)pubCompData;
///
- (void)mqtt5:(CocoaMQTT5 * _Nonnull)mqtt5 didStateChangeTo:(enum CocoaMQTTConnState)state;
@end


/// MQTT Message
SWIFT_CLASS("_TtC10IoTConnect17CocoaMQTT5Message")
@interface CocoaMQTT5Message : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end



@interface CocoaMQTT5Message (SWIFT_EXTENSION(IoTConnect))
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end

typedef SWIFT_ENUM(uint8_t, CocoaMQTTAUTHReasonCode, open) {
  CocoaMQTTAUTHReasonCodeSuccess = 0x00,
  CocoaMQTTAUTHReasonCodeContinueAuthentication = 0x18,
  CocoaMQTTAUTHReasonCodeReAuthenticate = 0x19,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTCONNACKReasonCode, open) {
  CocoaMQTTCONNACKReasonCodeSuccess = 0x00,
  CocoaMQTTCONNACKReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTCONNACKReasonCodeMalformedPacket = 0x81,
  CocoaMQTTCONNACKReasonCodeProtocolError = 0x82,
  CocoaMQTTCONNACKReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTCONNACKReasonCodeUnsupportedProtocolVersion = 0x84,
  CocoaMQTTCONNACKReasonCodeClientIdentifierNotValid = 0x85,
  CocoaMQTTCONNACKReasonCodeBadUsernameOrPassword = 0x86,
  CocoaMQTTCONNACKReasonCodeNotAuthorized = 0x87,
  CocoaMQTTCONNACKReasonCodeServerUnavailable = 0x88,
  CocoaMQTTCONNACKReasonCodeServerBusy = 0x89,
  CocoaMQTTCONNACKReasonCodeBanned = 0x8A,
  CocoaMQTTCONNACKReasonCodeBadAuthenticationMethod = 0x8C,
  CocoaMQTTCONNACKReasonCodeTopicNameInvalid = 0x90,
  CocoaMQTTCONNACKReasonCodePacketTooLarge = 0x95,
  CocoaMQTTCONNACKReasonCodeQuotaExceeded = 0x97,
  CocoaMQTTCONNACKReasonCodePayloadFormatInvalid = 0x99,
  CocoaMQTTCONNACKReasonCodeRetainNotSupported = 0x9A,
  CocoaMQTTCONNACKReasonCodeQosNotSupported = 0x9B,
  CocoaMQTTCONNACKReasonCodeUseAnotherServer = 0x9C,
  CocoaMQTTCONNACKReasonCodeServerMoved = 0x9D,
  CocoaMQTTCONNACKReasonCodeConnectionRateExceeded = 0x9F,
};

/// Conn Ack
typedef SWIFT_ENUM(uint8_t, CocoaMQTTConnAck, open) {
  CocoaMQTTConnAckAccept = 0,
  CocoaMQTTConnAckUnacceptableProtocolVersion = 1,
  CocoaMQTTConnAckIdentifierRejected = 2,
  CocoaMQTTConnAckServerUnavailable = 3,
  CocoaMQTTConnAckBadUsernameOrPassword = 4,
  CocoaMQTTConnAckNotAuthorized = 5,
  CocoaMQTTConnAckReserved = 6,
};

/// Connection State
typedef SWIFT_ENUM(uint8_t, CocoaMQTTConnState, open) {
  CocoaMQTTConnStateDisconnected = 0,
  CocoaMQTTConnStateConnecting = 1,
  CocoaMQTTConnStateConnected = 2,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTDISCONNECTReasonCode, open) {
  CocoaMQTTDISCONNECTReasonCodeNormalDisconnection = 0x00,
  CocoaMQTTDISCONNECTReasonCodeDisconnectWithWillMessage = 0x04,
  CocoaMQTTDISCONNECTReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTDISCONNECTReasonCodeMalformedPacket = 0x81,
  CocoaMQTTDISCONNECTReasonCodeProtocolError = 0x82,
  CocoaMQTTDISCONNECTReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTDISCONNECTReasonCodeNotAuthorized = 0x87,
  CocoaMQTTDISCONNECTReasonCodeServerBusy = 0x89,
  CocoaMQTTDISCONNECTReasonCodeServerShuttingDown = 0x8B,
  CocoaMQTTDISCONNECTReasonCodeKeepAliveTimeout = 0x8D,
  CocoaMQTTDISCONNECTReasonCodeSessionTakenOver = 0x8E,
  CocoaMQTTDISCONNECTReasonCodeTopicFilterInvalid = 0x8F,
  CocoaMQTTDISCONNECTReasonCodeTopicNameInvalid = 0x90,
  CocoaMQTTDISCONNECTReasonCodeReceiveMaximumExceeded = 0x93,
  CocoaMQTTDISCONNECTReasonCodeTopicAliasInvalid = 0x94,
  CocoaMQTTDISCONNECTReasonCodePacketTooLarge = 0x95,
  CocoaMQTTDISCONNECTReasonCodeMessageRateTooHigh = 0x96,
  CocoaMQTTDISCONNECTReasonCodeQuotaExceeded = 0x97,
  CocoaMQTTDISCONNECTReasonCodeAdministrativeAction = 0x98,
  CocoaMQTTDISCONNECTReasonCodePayloadFormatInvalid = 0x99,
  CocoaMQTTDISCONNECTReasonCodeRetainNotSupported = 0x9A,
  CocoaMQTTDISCONNECTReasonCodeQosNotSupported = 0x9B,
  CocoaMQTTDISCONNECTReasonCodeUseAnotherServer = 0x9C,
  CocoaMQTTDISCONNECTReasonCodeServerMoved = 0x9D,
  CocoaMQTTDISCONNECTReasonCodeSharedSubscriptionsNotSupported = 0x9E,
  CocoaMQTTDISCONNECTReasonCodeConnectionRateExceeded = 0x9F,
  CocoaMQTTDISCONNECTReasonCodeMaximumConnectTime = 0xA0,
  CocoaMQTTDISCONNECTReasonCodeSubscriptionIdentifiersNotSupported = 0xA1,
  CocoaMQTTDISCONNECTReasonCodeWildcardSubscriptionsNotSupported = 0xA2,
};

@class CocoaMQTTMessage;

/// CocoaMQTT Delegate
SWIFT_PROTOCOL("_TtP10IoTConnect17CocoaMQTTDelegate_")
@protocol CocoaMQTTDelegate
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didConnectAck:(enum CocoaMQTTConnAck)ack;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didPublishMessage:(CocoaMQTTMessage * _Nonnull)message id:(uint16_t)id;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didPublishAck:(uint16_t)id;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didReceiveMessage:(CocoaMQTTMessage * _Nonnull)message id:(uint16_t)id;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didSubscribeTopics:(NSDictionary * _Nonnull)success failed:(NSArray<NSString *> * _Nonnull)failed;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didUnsubscribeTopics:(NSArray<NSString *> * _Nonnull)topics;
///
- (void)mqttDidPing:(CocoaMQTT * _Nonnull)mqtt;
///
- (void)mqttDidReceivePong:(CocoaMQTT * _Nonnull)mqtt;
///
- (void)mqttDidDisconnect:(CocoaMQTT * _Nonnull)mqtt withError:(NSError * _Nullable)err;
@optional
/// Manually validate SSL/TLS server certificate.
/// This method will be called if enable  <code>allowUntrustCACertificate</code>
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didReceive:(SecTrustRef _Nonnull)trust completionHandler:(void (^ _Nonnull)(BOOL))completionHandler;
- (void)mqttUrlSession:(CocoaMQTT * _Nonnull)mqtt didReceiveTrust:(SecTrustRef _Nonnull)trust didReceiveChallenge:(NSURLAuthenticationChallenge * _Nonnull)challenge completionHandler:(void (^ _Nonnull)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didPublishComplete:(uint16_t)id;
///
- (void)mqtt:(CocoaMQTT * _Nonnull)mqtt didStateChangeTo:(enum CocoaMQTTConnState)state;
@end


SWIFT_CLASS("_TtC10IoTConnect15CocoaMQTTLogger")
@interface CocoaMQTTLogger : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


/// MQTT Message
SWIFT_CLASS("_TtC10IoTConnect16CocoaMQTTMessage")
@interface CocoaMQTTMessage : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


@interface CocoaMQTTMessage (SWIFT_EXTENSION(IoTConnect))
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end


typedef SWIFT_ENUM(uint8_t, CocoaMQTTPUBACKReasonCode, open) {
  CocoaMQTTPUBACKReasonCodeSuccess = 0x00,
  CocoaMQTTPUBACKReasonCodeNoMatchingSubscribers = 0x10,
  CocoaMQTTPUBACKReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTPUBACKReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTPUBACKReasonCodeNotAuthorized = 0x87,
  CocoaMQTTPUBACKReasonCodeTopicNameInvalid = 0x90,
  CocoaMQTTPUBACKReasonCodePacketIdentifierInUse = 0x91,
  CocoaMQTTPUBACKReasonCodeQuotaExceeded = 0x97,
  CocoaMQTTPUBACKReasonCodePayloadFormatInvalid = 0x99,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTPUBCOMPReasonCode, open) {
  CocoaMQTTPUBCOMPReasonCodeSuccess = 0x00,
  CocoaMQTTPUBCOMPReasonCodePacketIdentifierNotFound = 0x92,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTPUBRECReasonCode, open) {
  CocoaMQTTPUBRECReasonCodeSuccess = 0x00,
  CocoaMQTTPUBRECReasonCodeNoMatchingSubscribers = 0x10,
  CocoaMQTTPUBRECReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTPUBRECReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTPUBRECReasonCodeNotAuthorized = 0x87,
  CocoaMQTTPUBRECReasonCodeTopicNameInvalid = 0x90,
  CocoaMQTTPUBRECReasonCodePacketIdentifierInUse = 0x91,
  CocoaMQTTPUBRECReasonCodeQuotaExceeded = 0x97,
  CocoaMQTTPUBRECReasonCodePayloadFormatInvalid = 0x99,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTPUBRELReasonCode, open) {
  CocoaMQTTPUBRELReasonCodeSuccess = 0x00,
  CocoaMQTTPUBRELReasonCodePacketIdentifierNotFound = 0x92,
};

/// Quality of Service levels
typedef SWIFT_ENUM(uint8_t, CocoaMQTTQoS, open) {
/// At most once delivery
  CocoaMQTTQoSQos0 = 0,
/// At least once delivery
  CocoaMQTTQoSQos1 = 1,
/// Exactly once delivery
  CocoaMQTTQoSQos2 = 2,
/// !!! Used SUBACK frame only
  CocoaMQTTQoSFAILURE = 0x80,
};

typedef SWIFT_ENUM(uint8_t, CocoaMQTTSUBACKReasonCode, open) {
  CocoaMQTTSUBACKReasonCodeGrantedQoS0 = 0x00,
  CocoaMQTTSUBACKReasonCodeGrantedQoS1 = 0x01,
  CocoaMQTTSUBACKReasonCodeGrantedQoS2 = 0x02,
  CocoaMQTTSUBACKReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTSUBACKReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTSUBACKReasonCodeNotAuthorized = 0x87,
  CocoaMQTTSUBACKReasonCodeTopicFilterInvalid = 0x8F,
  CocoaMQTTSUBACKReasonCodePacketIdentifierInUse = 0x91,
  CocoaMQTTSUBACKReasonCodeQuotaExceeded = 0x97,
  CocoaMQTTSUBACKReasonCodeSharedSubscriptionsNotSupported = 0x9E,
  CocoaMQTTSUBACKReasonCodeSubscriptionIdentifiersNotSupported = 0xA1,
  CocoaMQTTSUBACKReasonCodeWildcardSubscriptionsNotSupported = 0xA2,
};


SWIFT_CLASS("_TtC10IoTConnect15CocoaMQTTSocket")
@interface CocoaMQTTSocket : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


@class MGCDAsyncSocket;
@class NSData;

@interface CocoaMQTTSocket (SWIFT_EXTENSION(IoTConnect)) <MGCDAsyncSocketDelegate>
- (void)socket:(MGCDAsyncSocket * _Nonnull)sock didConnectToHost:(NSString * _Nonnull)host port:(uint16_t)port;
- (void)socket:(MGCDAsyncSocket * _Nonnull)sock didReceiveTrust:(SecTrustRef _Nonnull)trust completionHandler:(void (^ _Nonnull)(BOOL))completionHandler;
- (void)socketDidSecure:(MGCDAsyncSocket * _Nonnull)sock;
- (void)socket:(MGCDAsyncSocket * _Nonnull)sock didWriteDataWithTag:(NSInteger)tag;
- (void)socket:(MGCDAsyncSocket * _Nonnull)sock didReadData:(NSData * _Nonnull)data withTag:(NSInteger)tag;
- (void)socketDidDisconnect:(MGCDAsyncSocket * _Nonnull)sock withError:(NSError * _Nullable)err;
@end

typedef SWIFT_ENUM(uint8_t, CocoaMQTTUNSUBACKReasonCode, open) {
  CocoaMQTTUNSUBACKReasonCodeSuccess = 0x00,
  CocoaMQTTUNSUBACKReasonCodeNoSubscriptionExisted = 0x11,
  CocoaMQTTUNSUBACKReasonCodeUnspecifiedError = 0x80,
  CocoaMQTTUNSUBACKReasonCodeImplementationSpecificError = 0x83,
  CocoaMQTTUNSUBACKReasonCodeNotAuthorized = 0x87,
  CocoaMQTTUNSUBACKReasonCodeTopicFilterInvalid = 0x8F,
  CocoaMQTTUNSUBACKReasonCodePacketIdentifierInUse = 0x91,
};

typedef SWIFT_ENUM(uint8_t, CocoaRetainHandlingOption, open) {
  CocoaRetainHandlingOptionSendOnSubscribe = 0,
  CocoaRetainHandlingOptionSendOnlyWhenSubscribeIsNew = 1,
  CocoaRetainHandlingOptionNone = 2,
};


SWIFT_CLASS("_TtCC10IoTConnect18CocoaMQTTWebSocket20FoundationConnection")
@interface FoundationConnection : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

@class NSURLSession;
@class NSURLSessionTask;
@class NSURLSessionWebSocketTask;

SWIFT_AVAILABILITY(tvos,introduced=13.0) SWIFT_AVAILABILITY(watchos,introduced=6.0) SWIFT_AVAILABILITY(ios,introduced=13.0) SWIFT_AVAILABILITY(macos,introduced=10.15)
@interface FoundationConnection (SWIFT_EXTENSION(IoTConnect)) <NSURLSessionWebSocketDelegate>
- (void)URLSession:(NSURLSession * _Nonnull)session task:(NSURLSessionTask * _Nonnull)task didReceiveChallenge:(NSURLAuthenticationChallenge * _Nonnull)challenge completionHandler:(void (^ _Nonnull)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
- (void)URLSession:(NSURLSession * _Nonnull)session webSocketTask:(NSURLSessionWebSocketTask * _Nonnull)webSocketTask didOpenWithProtocol:(NSString * _Nullable)protocol;
- (void)URLSession:(NSURLSession * _Nonnull)session webSocketTask:(NSURLSessionWebSocketTask * _Nonnull)webSocketTask didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode reason:(NSData * _Nullable)reason;
@end

@class NSStream;

SWIFT_CLASS("_TtC10IoTConnect16FoundationStream")
@interface FoundationStream : NSObject <NSStreamDelegate>
/// Delegate for the stream methods. Processes incoming bytes
- (void)stream:(NSStream * _Nonnull)aStream handleEvent:(NSStreamEvent)eventCode;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


/// Used for setting IoTConnect configuration.
/// author:
///
/// Devesh Mevada
/// \param cpId Provide a company identifier
///
/// \param uniqueId Device unique identifier
///
/// \param env Device environment
///
/// \param sdkOptions Device SDKOptions for SSL Certificates and Offline Storage
///
///
/// returns:
///
/// Returns nothing
SWIFT_CLASS("_TtC10IoTConnect16IoTConnectConfig")
@interface IoTConnectConfig : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC10IoTConnect18MqttAuthProperties")
@interface MqttAuthProperties : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect21MqttConnectProperties")
@interface MqttConnectProperties : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect17MqttDecodeConnAck")
@interface MqttDecodeConnAck : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect16MqttDecodePubAck")
@interface MqttDecodePubAck : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect17MqttDecodePubComp")
@interface MqttDecodePubComp : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect16MqttDecodePubRec")
@interface MqttDecodePubRec : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect16MqttDecodePubRel")
@interface MqttDecodePubRel : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect17MqttDecodePublish")
@interface MqttDecodePublish : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect16MqttDecodeSubAck")
@interface MqttDecodeSubAck : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect18MqttDecodeUnsubAck")
@interface MqttDecodeUnsubAck : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10IoTConnect21MqttPublishProperties")
@interface MqttPublishProperties : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM(uint8_t, PayloadFormatIndicator, open) {
  PayloadFormatIndicatorUnspecified = 0x00,
  PayloadFormatIndicatorUtf8 = 0x01,
};


SWIFT_CLASS("_TtC10IoTConnect9SDKClient")
@interface SDKClient : NSObject
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) SDKClient * _Nonnull shared;)
+ (SDKClient * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
/// Initialize configuration for IoTConnect SDK
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     config: Setup IoTConnectConfig
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)initializeWithConfig:(IoTConnectConfig * _Nonnull)config;
/// Used for sending data from Device to Cloud
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     data: Provide data in [[String:Any]] format
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)sendDataWithData:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)data;
/// Used for sending log from device to cloud
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     data: send log in [String: Any] format
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)sendLogWithData:(NSDictionary<NSString *, id> * _Nullable)data;
/// Send acknowledgement signal
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     data: send data in [[String:Any]] format
///   </li>
///   <li>
///     msgType: send msgType from anyone of this
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)sendAckWithData:(NSArray<NSDictionary<NSString *, id> *> * _Nonnull)data msgType:(NSString * _Nonnull)msgType;
/// Get all twins
/// author:
///
/// Devesh Mevada
///
/// returns:
///
/// Returns nothing
- (void)getAllTwins;
/// Updated twins
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     key: key in String format
///   </li>
///   <li>
///     value: value as any
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)updateTwinWithKey:(NSString * _Nonnull)key value:(id _Nonnull)value;
/// Dispose description
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     sdkconnection: description
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)disposeWithSdkconnection:(NSString * _Nonnull)sdkconnection;
/// Get attaributs
/// author:
///
/// Devesh Mevada
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     callBack:
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)getAttributesWithCallBack:(void (^ _Nonnull)(BOOL, NSArray<NSDictionary<NSString *, id> *> * _Nullable, NSString * _Nonnull))callBack;
/// Get device callback
/// author:
///
/// Keyur Prajapati
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     callBack:
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)getDeviceCallBackWithDeviceCallback:(void (^ _Nonnull)(id _Nullable))deviceCallback;
/// Get twin callback
/// author:
///
/// Keyur Prajapati
/// <ul>
///   <li>
///     parameters:
///   </li>
///   <li>
///     callBack:
///   </li>
/// </ul>
///
/// returns:
///
/// Returns nothing
- (void)getTwinUpdateCallBackWithTwinUpdateCallback:(void (^ _Nonnull)(id _Nullable))twinUpdateCallback;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end




SWIFT_CLASS("_TtC10IoTConnect9WebSocket")
@interface WebSocket : NSObject <NSStreamDelegate>
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#else
#error unsupported Swift architecture
#endif
