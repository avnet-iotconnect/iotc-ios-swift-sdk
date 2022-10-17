//
//  ErrosLog.swift
//  IoTConnect
//
//  Created by PC4111 on 20/08/21.
//

import Foundation

enum GenericErrors: Error {
    case unknownError
    case noInternetConnection
    case requestTimeout
    case invalidJson
    case unableToCreateRequest
    case emptyData
    case unacceptableStatusCode
    case unableToDecode
}

struct Log {//class
    enum Errors: String {
        case ERR_IN01 = "<<Exception error message>>"
        case ERR_IN02 = "Discovery URL can not be blank"
//        case ERR_IN03 = "Missing required parameter 'discoveryUrl' in sdkOptions"
//        case ERR_IN04 = "cpId can not be blank"
//        case ERR_IN05 = "uniqueId can not be blank"
        case ERR_IN06 = "SDK options : set proper certificate file path and try again"
//        case ERR_IN07 = "Log directory should be with proper permission to read and write"
//        case ERR_IN08 = "Network connection error or invalid url"
        case ERR_IN09 = "Unable to get baseUrl"
        case ERR_IN10 = "Device information not found"
        case ERR_IN11 = "Device broker information not found"
//        case ERR_IN12 = "CPID not found"
//        case ERR_IN13 = "Client connection failed."
        case ERR_IN14 = "Client connection closed"
//        case ERR_IN15 = "Missing required parameter 'cpId' or 'uniqueId' or 'env' to initialize the device connection"
//        case ERR_SD01 = "<<Exception error message>> "
        case ERR_SD02 = "It does not matched with payload's 'uniqueId'"
//        case ERR_SD03 = "It does not matched with predefined standard date time format for payload's 'time'"
//        case ERR_SD04 = "Device is barred SendData() method is not permitted"
//        case ERR_SD05 = "Invalid data type to send the data. It should be in array of object type"
        case ERR_SD06 = "Missing required parameter 'data'"
//        case ERR_SD07 = "Missing required parameter 'time'"
//        case ERR_SD08 = "Missing required parameter 'uniqueId'"
//        case ERR_SD09 = "Device information not found in local memory."
        case ERR_SD10 = "Publish data failed : MQTT connection not found"
//        case ERR_SD11 = "Unknown broker protocol"
        case ERR_TP01 = "<<Exception error message>>  "
        case ERR_TP02 = "Device is barred updateTwin() method is not permitted"
        case ERR_TP03 = "Missing required parameter 'key' or 'value' to update twin property"
        case ERR_TP04 = "Device is barred getAllTwins() method is not permitted"
        case ERR_CM01 = "<<Exception error message>>   "
        case ERR_CM02 = "Missing required parameter 'data' or 'msgType' to send acknowledgement"
//        case ERR_CM03 = "Invalid data type to send the acknowledgment. It should be in 'object' type"
        case ERR_CM04 = "Device is barred SendAck() method is not permitted"
        case ERR_OS01 = " <<Exception error message>>"
//        case ERR_OS02 = "Error while creating log directory"
//        case ERR_OS03 = "Unable to read or write file"
        case ERR_OS04 = "Unable to scan directory"
//        case ERR_DC01 = "<<Exception error message>>    "
        case ERR_DC02 = "Connection not available"
//        case ERR_DC03 = "Device is barred Dispose() method is not permitted"//...New
//        case ERR_GA01 = "<<Exception error message>>     "
        case ERR_GA02 = "Attributes data not found"
        //case ERR_GA03 = "Device is barred getAttributes() method is not permitted"//...New
//        case ERR_EE01 = "<<Exception error message>>      "
        case ERR_PS01 = "JSON parsing error"    //...New
    }
    enum Info: String {
        case INFO_IN01 = "Device information received successfully"
        case INFO_IN02 = "Device connected"
        case INFO_IN03 = "Device disconnected"
        case INFO_IN04 = "Initializing..."
        case INFO_IN05 = "Connecting..."
        case INFO_IN06 = "Rechecking..."
        case INFO_IN07 = "BaseUrl received to sync the device information"
        case INFO_IN08 = "Response Code : 0 'OK'"
        case INFO_IN09 = "Response Code : 1 'DEVICE_NOT_REGISTERED'"
        case INFO_IN10 = "Response Code : 2 'AUTO_REGISTER'"
        case INFO_IN11 = "Response Code : 3 'DEVICE_NOT_FOUND'"
        case INFO_IN12 = "Response Code : 4 'DEVICE_INACTIVE'"
        case INFO_IN13 = "Response Code : 5 'OBJECT_MOVED'"
        case INFO_IN14 = "Response Code : 6 'CPID_NOT_FOUND'"
        case INFO_IN15 = "Response Code : 'NO_RESPONSE_CODE_MATCHED'"

        case INFO_SD01 = "Publish data"

        case INFO_TP01 = "Twin property updated successfully"
        case INFO_TP02 = "Request sent successfully to get the all twin properties."

        case INFO_CM01 = "Command : 0x01 : STANDARD_COMMAND"
        case INFO_CM02 = "Command : 0x02 : FIRMWARE_UPDATE"
        case INFO_CM03 = "Command : 0x10 : ATTRIBUTE_UPDATE"
        case INFO_CM04 = "Command : 0x11 : SETTING_UPDATE"
        case INFO_CM05 = "Command : 0x12 : PASSWORD_UPDATE"
        case INFO_CM06 = "Command : 0x13 : DEVICE_UPDATE"
//        case INFO_CM07 = "Command : 0x15 : RULE_UPDATE"
        case INFO_CM08 = "Command : 0x99 : STOP_SDK_CONNECTION"
//        case INFO_CM09 = "Command : 0x16 : SDK_CONNECTION_STATUS"
        case INFO_CM10 = "Command acknowledgement success"
        case INFO_CM11 = "Command : 0x17 : DATA_FREQUENCY_UPDATE"

//        case INFO_OS01 = "Publish offline data"
        case INFO_OS02 = "Offline data saved"
        case INFO_OS03 = "File has been created to store offline data"
        case INFO_OS04 = "Offline log file deleted"
        case INFO_OS05 = "No offline data found"
        case INFO_OS06 = "Offline data publish :: Send/Total :: "

        case INFO_DC01 = "Device already disconnected"
//
        case INFO_GA01 = "Get attributes successfully"

//        case INFO_EE01 = "Edge Device :: Rule 'MATCHED'"
//        case INFO_EE02 = "Edge Device :: Rule 'NOT MATCHED'"
    }
}