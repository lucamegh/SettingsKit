/**
 * SettingsKit
 * Copyright (c) Luca Meghnagi 2021
 * MIT license, see LICENSE file for details
 */

import Combine
import Storage
import SwiftUI

@dynamicMemberLookup
public final class SettingsManager<Settings: SettingsProtocol>: ObservableObject {
    
    private let subject: CurrentValueSubject<Settings, Never>
    
    private let storage: Storage<Settings>
    
    public init(storage: Storage<Settings>) {
        let settings = storage.value ?? Settings()
        self.subject = CurrentValueSubject(settings)
        self.storage = storage
    }
    
    private func updateSettings(_ update: (inout Settings) -> Void) {
        objectWillChange.send()
        update(&subject.value)
        storage.store(subject.value)
    }
}

public extension SettingsManager {
    
    var settings: Settings {
        get {
            subject.value
        }
        set {
            updateSettings { settings in
                settings = newValue
            }
        }
    }
    
    func publisher<Value>(for keyPath: KeyPath<Settings, Value>) -> AnyPublisher<Value, Never> {
        subject
            .map(keyPath)
            .eraseToAnyPublisher()
    }
    
    func binding<Value>(for keyPath: WritableKeyPath<Settings, Value>) -> Binding<Value> {
        Binding(
            get: { [subject] in
                subject.value[keyPath: keyPath]
            },
            set: { [updateSettings] newValue in
                updateSettings { settings in
                    settings[keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Settings, Value>) -> Value {
        get {
            settings[keyPath: keyPath]
        }
        set {
            settings[keyPath: keyPath] = newValue
        }
    }
}

public extension SettingsManager where Settings: Codable {
    
    static var local: SettingsManager<Settings> {
        local(key: nil, userDefaults: .standard)
    }
    
    static var cloud: SettingsManager<Settings> {
        cloud(key: nil, ubiquitousKeyValueStore: .default)
    }
    
    static func local(
        key: String?,
        userDefaults: UserDefaults
    ) -> SettingsManager<Settings> {
        SettingsManager(
            storage: .userDefaults(
                key: key ?? defaultKey,
                userDefaults: userDefaults
            )
        )
    }
    
    static func cloud(
        key: String?,
        ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    ) -> SettingsManager<Settings> {
        SettingsManager(
            storage: .ubiquitousKeyValueStore(
                key: key ?? defaultKey,
                ubiquitousKeyValueStore: ubiquitousKeyValueStore
            )
        )
    }
    
    private static var defaultKey: String {
        "com.meghnagi.SettingsKit.\(Settings.self)"
    }
}

public protocol SettingsProtocol {
    
    init()
}
