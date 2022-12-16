//
//  CallManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/5.
//

import Foundation
import CallKit

class CallManager {
    var callsChangedHandler: (() -> Void)?
  
    private(set) var calls: [CallInformation] = []

    func callWithUUID(uuid: UUID) -> CallInformation? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
  
    func add(call: CallInformation) {
        calls.append(call)
        call.stateChanged = { [weak self] in
            guard let self = self else { return }
            self.callsChangedHandler?()
        }
        callsChangedHandler?()
    }
  
    func remove(call: CallInformation) {
        guard let index = calls.index(where: { $0 === call }) else { return }
        calls.remove(at: index)
        callsChangedHandler?()
    }
  
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
}
