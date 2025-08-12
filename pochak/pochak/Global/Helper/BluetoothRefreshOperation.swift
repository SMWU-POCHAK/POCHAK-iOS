//
//  BluetoothRefreshOperation.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/29/25.
//

import Foundation

final class BluetoothRefreshOperation: Operation {
    
    override func main() {
        if isCancelled {
            return
        }
        
        let date = Date()
        
        BluetoothSerialManager.shared.setBluetoothModeAndStart(to: .scanningMode)
        
        // 작업 완료 시 로그 출력
        print("Background task executed and date saved at \(date)")
    }
}
