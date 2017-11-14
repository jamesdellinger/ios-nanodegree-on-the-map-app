//
//  GCDPerformUIUpdates.swift
//  On the Map
//
//  Created by James Dellinger on 11/5/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
