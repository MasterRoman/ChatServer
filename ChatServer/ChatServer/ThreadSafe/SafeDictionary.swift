//
//  SafeDictionary.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation

class SafeDictionary<K : Hashable,V>: Collection {
    
    private var dictionary: [K:V]
    private let queue = DispatchQueue(label: "read.write.lock",attributes: .concurrent)
    var startIndex: Dictionary<K,V>.Index{
        return self.dictionary.startIndex
    }
    
    var endIndex: Dictionary<K,V>.Index{
        return self.dictionary.endIndex
    }
    
    init(dictionary : [K:V] = [K:V]()){
        self.dictionary = dictionary
    }
    
    subscript(key: K) -> V?{
        set(newValue) {
            self.queue.async(flags: .barrier) {[unowned self] in
                self.dictionary[key] = newValue
            }
        }
        get {
            self.queue.sync {
                return self.dictionary[key]
            }
        }
    }
    
    subscript(index: Dictionary<K,V>.Index) -> Dictionary<K,V>.Element{
        self.queue.sync { [unowned self] in
            return self.dictionary[index]
        }
    }
    
    func removeAll() {
        self.queue.async(flags: .barrier){[unowned self] in
            self.dictionary.removeAll()
        }
    }
    
    func index(after i: Dictionary<K,V>.Index) -> Dictionary<K,V>.Index{
        return self.dictionary.index(after: i)
    }
    
}
