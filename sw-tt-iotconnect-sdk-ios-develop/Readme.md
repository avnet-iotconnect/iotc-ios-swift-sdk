# IoTConnect SDK

IoTConnect Device SDKs (System Development Kit) are highly secure and reliable, solving the purpose of D2C (device to cloud) and C2D (cloud to device) communications. It is a mediator between device and cloud platforms.

IoTConnect Device SDKs help you to easily and quickly connect your devices to IoTConnect. IoTConnect Device SDKs include a set of tools, libraries, developer guides with code samples, and porting guides. IoTConnect SDK is a full-fledged workshop for you to build innovative IoT products or solutions on your choice of hardware platforms.

## Features
- Send Data
- Received Data
- OTA update
- Symantec Auth

## Third party Frameworks Used
- [CocoaMQTT] (https://github.com/emqx/CocoaMQTT) for MQTTClient connection
- [Starscream] (https://github.com/nuclearace/Starscream) for Websocket library
- [CocoaAsyncSocket] (https://github.com/robbiehanson/CocoaAsyncSocket) for socket library

## Build Details
- IDE
- - Please use Xcode 12.4 to compile
- Targets
- - IoTConnect
- - IoTConnectDemo
- Key Branches
- -  **develop:** contains the latest dev code.
- - **master:** this contains the code for the current app store release.

## Usage

```Swift
import IoTConnect

let objConfig = IoTConnectConfig(cpId: "{replace-with-your-id}",
                                         uniqueId: "{replace-with-your-id}",
                                         env: .QA,
                                         mqttConnectionType: .userCredntialAuthentication,
                                         sdkOptions: nil)
SDKClient.shared.initialize(config: objConfig)

SDKClient.shared.getDeviceCallBack { (message) in
  print("message: ", message as Any)
}

SDKClient.shared.getTwinUpdateCallBack { (twinMessage) in
  print("twinMessage: ", twinMessage as Any)
}

```


## License
[Softweb Proprietor](https://www.softwebsolutions.com)
